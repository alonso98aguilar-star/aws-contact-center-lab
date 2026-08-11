# Fase 4 — Integración: Connect → Lambda → DynamoDB → CloudWatch

## Qué se conectó

```
Amazon Connect (chat)
        │  invoca de forma síncrona
        ▼
AWS Lambda: contact-center-processor
        │                       │
        ▼                       ▼
DynamoDB: ContactRecords   CloudWatch Logs: /aws/lambda/contact-center-processor
```

### 1. Rol IAM para el Lambda (`contact-center-lambda-role`)

Permisos mínimos necesarios (principio de menor privilegio):
- `AWSLambdaBasicExecutionRole` (política administrada) → permite escribir logs
  en CloudWatch.
- Política en línea `ContactRecordsWriteAccess` → **solo** `dynamodb:PutItem`,
  y **solo** sobre el ARN exacto de la tabla `ContactRecords`. El Lambda no
  puede leer, borrar, ni tocar ninguna otra tabla.

### 2. Función Lambda (`lambda/contact_processor.py`)

Recibe el evento que Connect manda a un bloque "Invoke AWS Lambda function"
(`event["Details"]["ContactData"]`), extrae `ContactId`, `Channel` y el
número del cliente si existe, y escribe un ítem en `ContactRecords`. Cualquier
excepción se loguea con el prefijo `ERROR` — así la dispara el metric filter
de la Fase 2 y, si pasa el umbral, la alarma `contact-center-lambda-errors`.

```bash
aws lambda create-function \
  --function-name contact-center-processor \
  --runtime python3.13 \
  --role arn:aws:iam::<account-id>:role/contact-center-lambda-role \
  --handler contact_processor.lambda_handler \
  --zip-file fileb://lambda/function.zip \
  --timeout 10
```

### 3. Asociar el Lambda a la instancia de Connect

Antes de poder usarlo dentro de un contact flow, hay que autorizarlo a nivel
de instancia:

```bash
aws connect associate-lambda-function \
  --instance-id <instance-id> \
  --function-arn arn:aws:lambda:us-east-1:<account-id>:function:contact-center-processor
```

### 4. Conectarlo en el flujo (consola)

Se usó el flujo de ejemplo **"Sample Lambda integration"**: en el bloque
"AWS Lambda function" se seleccionó `contact-center-processor` en el campo
**Function ARN → Set manually**, y se publicó el flujo.

### 5. Probar

**Channels → Chat → Test Chat → Test Settings** → elegir el flujo
"Sample Lambda integration" → activar el Contact Control Panel → iniciar
chat desde el lado del cliente.

## Resultado verificado

Con un solo mensaje de chat de prueba:

- El Lambda corrió en **~520ms**, sin errores.
- Quedó un ítem en `ContactRecords`:
  ```json
  {
    "contact_id": "6db3fe9a-e4dd-49ed-8f23-20abb781f1b7",
    "channel": "CHAT",
    "timestamp": "2026-08-11T20:02:31.342398+00:00",
    "customer_number": "N/A",
    "status": "RECEIVED"
  }
  ```
- El log en CloudWatch (`/aws/lambda/contact-center-processor`) muestra el
  evento completo recibido de Connect y la confirmación de guardado.

Verificación por CLI:

```bash
aws dynamodb scan --table-name ContactRecords
aws logs tail /aws/lambda/contact-center-processor --since 20m
```

## Aprendizajes / notas

- El evento que Connect manda al Lambda trae mucho más que el `ContactId`:
  canal, idioma, cola, atributos del contact flow, etc. — todo bajo
  `Details.ContactData`.
- `customer_number` salió `"N/A"` porque el chat de prueba no simula un
  número de teléfono real (`CustomerEndpoint` viene `null`) — con un canal de
  voz real sí vendría poblado.
- El flujo de ejemplo espera un atributo `FunFact` que este Lambda no genera;
  no rompe nada, solo ese texto queda vacío en el prompt de salida.

_(agrega aquí lo que más te costó de esta fase)_
