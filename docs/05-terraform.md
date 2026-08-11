# Fase 5 — Migrar a Infraestructura como Código (Terraform)

## Por qué

Hasta la Fase 4, todo se creó a mano: comandos de `aws cli` sueltos y clics en
la consola. Funciona, pero tiene problemas reales:

- Si borras la tabla de DynamoDB sin querer, no hay un solo lugar que te diga
  "así se veía, así la vuelves a crear".
- No hay forma de revisar en GitHub *qué cambió* en la infraestructura entre
  una semana y otra (un `git diff` de un archivo `.tf` sí lo muestra).
- No es reproducible: si quisieras un segundo entorno (`dev`/`prod`), tocaría
  repetir todos los comandos a mano.

**Terraform** resuelve esto describiendo la infraestructura como código
(`.tf`, lenguaje HCL) y llevando un **state file** (`terraform.tfstate`) que
mapea cada recurso del código con el recurso real en AWS.

## La decisión clave: importar, no recrear

Ya había recursos reales corriendo (Fases 1-4). Dos caminos:

1. Borrar todo y que Terraform lo cree de cero.
2. **Adoptar lo existente** con `terraform import`, sin tocarlo.

Se eligió la opción 2 — es lo que se hace en el mundo real cuando una empresa
decide pasar infraestructura ya viva a IaC (nadie borra producción para
reescribirla en Terraform). Terraform 1.5+ soporta esto de forma declarativa
con **bloques `import`** dentro del propio código (en vez del comando
`terraform import` suelto por CLI, que no queda registrado en ningún lado).

## Instalación

Homebrew ya no distribuye Terraform directamente (HashiCorp cambió de
licencia en 2023 y Homebrew retiró la fórmula oficial). Hay que usar el tap
de HashiCorp:

```bash
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
```

## Estructura de `terraform/`

| Archivo | Contenido |
|---|---|
| `versions.tf` | Versión de Terraform y providers requeridos (`aws`, `archive`) |
| `variables.tf` | Parámetros (región, alias de la instancia) |
| `iam.tf` | Rol del Lambda + política de acceso a DynamoDB |
| `dynamodb.tf` | Tabla `ContactRecords` |
| `cloudwatch.tf` | Log group, metric filter y alarma |
| `lambda.tf` | Función Lambda (el `.zip` se genera con el provider `archive` a partir de `lambda/contact_processor.py`) |
| `connect.tf` | Instancia de Connect, usuario admin, asociación del Lambda |
| `outputs.tf` | Valores útiles (ARNs, nombres) tras aplicar |

## El proceso de importación

1. Se escribió cada recurso `.tf` para que coincidiera **exactamente** con lo
   que ya existía en AWS (mismo nombre, mismos parámetros).
2. Se agregó un bloque `import` por recurso, por ejemplo:
   ```hcl
   import {
     to = aws_dynamodb_table.contact_records
     id = "ContactRecords"
   }
   ```
3. `terraform plan` mostró qué iba a importar y qué diferencias mínimas
   había entre el código y la realidad.
4. Tras confirmar **`0 to destroy`**, se corrió `terraform apply`.
5. Una vez importado, se **borraron los bloques `import`** (ya cumplieron su
   propósito; dejarlos no aporta nada más).

Resultado: **11 recursos importados, 0 destruidos.** El chat de prueba y el
Lambda siguieron funcionando exactamente igual, sin ninguna interrupción.

### Decisiones de diseño durante la importación

- **`Admin` (security profile) y `Basic Routing Profile`** no se modelaron
  como recursos de Terraform — los crea Connect automáticamente al
  provisionar la instancia, y tratar de "crearlos" con Terraform hubiera
  chocado con los que ya existen. En su lugar se consultan por nombre con
  `data "aws_connect_security_profile"` / `data "aws_connect_routing_profile"`
  — Terraform los *lee*, no los *administra*.
- **Los contact flows (el diseño visual del flujo de chat) se dejaron fuera**
  de Terraform a propósito. Son ~20 flujos de ejemplo que trae la instancia
  por defecto, se editan visualmente en la consola, y modelarlos en HCL en
  esta etapa del aprendizaje agregaría complejidad sin aportar mucho. Se
  documentan en [docs/03-connect.md](03-connect.md) y
  [docs/04-integracion.md](04-integracion.md), y siguen administrándose
  desde la consola.
- El ID de importación no es el mismo formato para todos los recursos —
  cada uno lo define el provider (ej. rol IAM = nombre; usuario de Connect =
  `instance_id:user_id`; log metric filter = `log_group:filter_name`). Se
  descubrieron por ensayo y error leyendo los mensajes de `terraform plan`.

## Verificación de idempotencia

Después de importar, se corrió `terraform plan` de nuevo sin cambiar nada:

```
No changes. Your infrastructure matches the configuration.
```

Esto confirma que el código `.tf` describe fielmente lo que existe — la
prueba de que la migración fue exitosa.

## Cómo se usa de aquí en adelante

Cualquier cambio a la infraestructura ahora se hace editando el `.tf`
correspondiente, no la consola:

```bash
cd terraform
terraform plan    # ver qué cambiaría, antes de aplicar nada
terraform apply   # aplicar los cambios
```

Ejemplo: para cambiar la retención de logs de 14 a 30 días, se editaría
`retention_in_days = 14` a `30` en `cloudwatch.tf` y se correría
`terraform plan` / `apply` — no se tocaría la consola.

## Limitaciones conocidas (para la siguiente iteración de aprendizaje)

- **State local**: `terraform.tfstate` vive solo en este Mac (no está en
  git, por seguridad — contiene ARNs y metadata de todos los recursos). Si
  se pierde el archivo, Terraform "olvida" qué administra, aunque los
  recursos en AWS sigan ahí (se podrían re-importar). En un equipo real se
  usaría un **backend remoto** (S3 + DynamoDB para locking) para que el
  estado sea compartido y no se pise entre personas.
- **Sin pipeline de CI/CD**: los `terraform apply` se corren a mano desde la
  terminal. El siguiente paso natural sería correr `terraform plan` en un
  GitHub Action en cada PR.

## Aprendizajes / notas

_(agrega aquí qué se te hizo más difícil de entender: el concepto de state,
los bloques `import`, o algo de la sintaxis de HCL)_
