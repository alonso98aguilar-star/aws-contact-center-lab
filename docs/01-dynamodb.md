# Fase 1 — DynamoDB: tabla de contactos

## Qué se creó

Tabla `ContactRecords` en `us-east-1`, para guardar un registro por cada contacto
(llamada/chat) que pase por Amazon Connect.

- **Clave primaria (partition key)**: `contact_id` (String) — coincide con el
  `ContactId` que genera Amazon Connect por cada interacción, así el Lambda
  puede escribir usando ese mismo valor sin necesidad de generar un ID propio.
- **Modo de facturación**: `PAY_PER_REQUEST` (on-demand) — no hay que estimar
  capacidad de lectura/escritura de antemano, y no genera costo si la tabla
  no se usa. Ideal para un laboratorio con tráfico impredecible/bajo.

## Comando usado

```bash
aws dynamodb create-table \
  --table-name ContactRecords \
  --attribute-definitions AttributeName=contact_id,AttributeType=S \
  --key-schema AttributeName=contact_id,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-east-1
```

## Verificación

```bash
aws dynamodb describe-table --table-name ContactRecords --region us-east-1 \
  --query 'Table.TableStatus' --output text
# ACTIVE
```

## Atributos que se guardarán por contacto (definidos por la app, no por la tabla)

DynamoDB es NoSQL — solo la partition key es fija; el resto de atributos los
define el Lambda al escribir el ítem. Plan para este lab:

| Atributo | Tipo | Descripción |
|---|---|---|
| `contact_id` | S | ID del contacto (partition key) |
| `channel` | S | `VOICE`, `CHAT`, etc. |
| `timestamp` | S | Fecha/hora ISO 8601 del contacto |
| `customer_number` | S | Número o identificador del cliente (si aplica) |
| `status` | S | Resultado del contacto |

## Aprendizajes / notas

_(agrega aquí lo que aprendiste en este paso)_
