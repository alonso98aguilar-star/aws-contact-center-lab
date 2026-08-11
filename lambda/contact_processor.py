import json
import logging
from datetime import datetime, timezone

import boto3

logger = logging.getLogger()
logger.setLevel(logging.INFO)

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table("ContactRecords")


def lambda_handler(event, context):
    """Invocado por un contact flow de Amazon Connect. Guarda un registro
    del contacto en DynamoDB y devuelve atributos que el flow puede usar."""
    logger.info("Evento recibido: %s", json.dumps(event))

    try:
        contact_data = event["Details"]["ContactData"]
        contact_id = contact_data["ContactId"]
        channel = contact_data.get("Channel", "UNKNOWN")
        customer_endpoint = contact_data.get("CustomerEndpoint") or {}

        item = {
            "contact_id": contact_id,
            "channel": channel,
            "timestamp": datetime.now(timezone.utc).isoformat(),
            "customer_number": customer_endpoint.get("Address", "N/A"),
            "status": "RECEIVED",
        }

        table.put_item(Item=item)
        logger.info("Registro guardado en DynamoDB: %s", item)

        return {
            "recordSaved": "true",
            "contactId": contact_id,
        }

    except Exception:
        logger.error("ERROR procesando el contacto: %s", json.dumps(event), exc_info=True)
        return {
            "recordSaved": "false",
        }
