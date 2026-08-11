# Fase 3 — Amazon Connect: instancia y flujo de contacto

## Qué se creó

### Instancia
- **Alias**: `contact-center-lab-aguilar`
- **Región**: `us-east-1` (N. Virginia) — importante: Amazon Connect no está
  disponible en todas las regiones (ej. no está en Ohio/us-east-2, hay que
  revisar disponibilidad antes de elegir región).
- **Identity management**: `CONNECT_MANAGED` — los usuarios (agentes/admins)
  viven dentro de la instancia de Connect, no en un directorio externo. Más
  simple para un lab; en una empresa real se conectaría a AWS SSO/SAML/Active
  Directory.
- **URL de acceso**: `https://contact-center-lab-aguilar.my.connect.aws`

Al crear la instancia, Connect provisiona automáticamente recursos por
defecto: security profiles (`Admin`, `Agent`, `CallCenterManager`,
`QualityAnalyst`), un `Basic Routing Profile`, y ~20 contact flows de ejemplo
(saludo, desconexión, cola, e incluso uno de ejemplo con integración a
Lambda: `Sample Lambda integration`, que se usará en la Fase 4).

### Usuario administrador
Se creó con `aws connect create-user`, usando el security profile `Admin` y el
`Basic Routing Profile`. Esto es un usuario **dentro de Connect**, distinto
del usuario IAM (`Lab-admin`) — uno controla la cuenta de AWS, el otro
controla el panel de agente/administración de Connect.

## Probar sin número de teléfono: Test Chat

Amazon Connect permite probar un contact flow de canal chat sin reclamar
ningún número (evita costos). Se encuentra en:

**Channels → Chat → Test Chat**

Esta página simula dos lados:
- **Izquierda**: la página web del cliente (con un widget de chat).
- **Derecha**: el Contact Control Panel (CCP), la vista del agente — hay que
  darle clic a "Activate the Contact Control Panel" primero.

Al iniciar el chat desde la izquierda, el contacto entra al
**"Sample inbound flow (first contact experience)"** (el flujo por defecto),
que se publicó (`Publish`) antes de probarlo — un flujo debe estar publicado
para que el Test Chat lo use.

## Resultado

✅ Chat de prueba funcionando end-to-end entre el simulador de cliente y el
panel de agente, usando el flujo de entrada por defecto.

## Aprendizajes / notas

- El botón de prueba de chat **no está dentro del editor del flujo** — está
  en una sección aparte (Channels → Chat), lo cual no es obvio la primera vez.
- Un flujo debe estar "Published" (no solo guardado) para poder probarse.

_(agrega aquí lo que más te costó entender de Connect)_
