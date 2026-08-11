# Fase 2 — CloudWatch: logs, métrica de errores y alarma

## Qué se creó

### 1. Log group
`/aws/lambda/contact-center-processor` — este es el nombre que Lambda usa
automáticamente para el log group de una función llamada `contact-center-processor`
(convención `/aws/lambda/<nombre-de-la-función>`). Se creó *antes* de crear el
Lambda para poder fijar la política de retención desde ya.

- **Retención**: 14 días. Por defecto, CloudWatch Logs guarda los logs
  *para siempre* (y cobra por ese almacenamiento indefinidamente) si no se fija
  una retención. Para un lab, no tiene sentido pagar por logs viejos.

### 2. Metric filter
`ErrorCount` sobre ese log group: busca la palabra `ERROR` en cada línea de log
y, cuando la encuentra, publica 1 al namespace/métrica personalizada
`ContactCenterLab / LambdaErrors`.

- Esto convierte texto de logs en un número medible con el que CloudWatch
  puede evaluar alarmas — los logs por sí solos no disparan alarmas, las
  métricas sí.

### 3. Alarma
`contact-center-lambda-errors`: se dispara si `LambdaErrors` suma ≥1 en una
ventana de 5 minutos (`period=300`, `evaluation-periods=1`).

- `treat-missing-data notBreaching`: si no hay datos (el Lambda no se ha
  invocado), la alarma se considera "OK", no "en alarma". Sin esto, una
  función poco usada podría disparar falsas alarmas solo por falta de datos.
- **No tiene acción configurada** (no envía email/SNS) — en este lab solo
  cambiará de estado visualmente en la consola. En un entorno real se
  conectaría a un tema de SNS para notificar por email/Slack.

## Comandos usados

```bash
aws logs create-log-group --log-group-name /aws/lambda/contact-center-processor
aws logs put-retention-policy --log-group-name /aws/lambda/contact-center-processor --retention-in-days 14

aws logs put-metric-filter \
  --log-group-name /aws/lambda/contact-center-processor \
  --filter-name ErrorCount \
  --filter-pattern "ERROR" \
  --metric-transformations metricName=LambdaErrors,metricNamespace=ContactCenterLab,metricValue=1,defaultValue=0

aws cloudwatch put-metric-alarm \
  --alarm-name contact-center-lambda-errors \
  --namespace ContactCenterLab \
  --metric-name LambdaErrors \
  --statistic Sum --period 300 --evaluation-periods 1 \
  --threshold 1 --comparison-operator GreaterThanOrEqualToThreshold \
  --treat-missing-data notBreaching
```

## Verificación

```bash
aws cloudwatch describe-alarms --alarm-names contact-center-lambda-errors \
  --query 'MetricAlarms[0].{Nombre:AlarmName,Estado:StateValue}'
# Estado: INSUFFICIENT_DATA (esperado — el Lambda aún no existe)
```

Este estado cambiará a `OK` en cuanto el Lambda se despliegue y corra sin
errores, y a `ALARM` si registra algún `ERROR` en sus logs.

## Aprendizajes / notas

_(agrega aquí lo que aprendiste en este paso)_
