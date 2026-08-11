# Fase 0 — Seguridad: usuario IAM y AWS CLI

## Por qué

La cuenta root de AWS tiene acceso total sin restricciones y no debería usarse
para trabajo diario ni para el CLI. Buena práctica: crear un usuario IAM con
los permisos necesarios, activar MFA en la cuenta root, y usar ese usuario
IAM (con sus propias claves de acceso) para todo lo demás.

## Pasos

1. Entra a la [consola de AWS](https://console.aws.amazon.com/) con tu cuenta root.
2. Activa MFA en el usuario root (IAM → Usuarios → root → Seguridad → Asignar MFA)
   si no lo tienes ya. Usa una app como Google Authenticator o Authy.
3. Ve a **IAM → Usuarios → Crear usuario**.
   - Nombre: `lab-admin` (o el que prefieras)
   - Marca "Provide user access to the AWS Management Console" si quieres poder
     entrar también desde el navegador con este usuario (opcional).
4. Permisos: para este laboratorio, adjunta la política administrada
   `AdministratorAccess` directamente (más simple para aprender; en un entorno
   real se usarían políticas más restringidas).
5. Termina la creación del usuario.
6. Entra al usuario recién creado → pestaña **Security credentials** →
   **Create access key** → elige el caso de uso "Command Line Interface (CLI)"
   → confirma → **descarga el CSV con el Access Key ID y el Secret Access Key**.
   Esta es la única vez que verás el Secret Access Key.

## Configurar AWS CLI localmente

En Terminal:

```bash
aws configure
```

Te pedirá:
- **AWS Access Key ID**: el del CSV que descargaste
- **AWS Secret Access Key**: el del CSV
- **Default region name**: `us-east-1` (Amazon Connect no está en todas las
  regiones; `us-east-1` es una apuesta segura)
- **Default output format**: `json`

## Verificación

```bash
aws sts get-caller-identity
```

Debe mostrar el ARN de `lab-admin`, **no** el de root.

## Aprendizajes / notas

_(agrega aquí lo que aprendiste o lo que te costó trabajo en este paso)_
