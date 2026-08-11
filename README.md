# AWS Contact Center Lab

Laboratorio de aprendizaje: simular un contact center completo usando AWS —
Amazon Connect, IAM, DynamoDB, CloudWatch y Lambda como pegamento entre servicios.

Este repo documenta el proceso paso a paso: qué se construyó, por qué, qué salió mal,
y qué se aprendió. Cada fase tiene su propio documento en [docs/](docs/).

## Arquitectura objetivo

```
Llamada/chat entrante
        │
        ▼
  Amazon Connect (contact flow)
        │
        ▼
   AWS Lambda  ───────────────►  Amazon CloudWatch (logs y métricas)
        │
        ▼
  Amazon DynamoDB (registro del contacto)
```

Todo el acceso entre servicios se controla con roles y políticas de IAM
con permisos mínimos necesarios (principio de menor privilegio).

## Fases

| Fase | Estado | Documento |
|---|---|---|
| 0. Seguridad: usuario IAM y AWS CLI | 🔜 | [docs/00-iam-setup.md](docs/00-iam-setup.md) |
| 1. DynamoDB: tabla de contactos | ⬜ | docs/01-dynamodb.md |
| 2. CloudWatch: logs y dashboard | ⬜ | docs/02-cloudwatch.md |
| 3. Amazon Connect: instancia y flujo | ⬜ | docs/03-connect.md |
| 4. Integración Connect → Lambda → DynamoDB | ⬜ | docs/04-integracion.md |
| 5. Prueba end-to-end | ⬜ | docs/05-pruebas.md |

## Costos

Amazon Connect, Lambda, DynamoDB y CloudWatch tienen capas gratuitas, pero
Connect cobra por número de teléfono reclamado y por minuto de uso. Revisar
[AWS Pricing](https://aws.amazon.com/connect/pricing/) antes de reclamar un número,
y **eliminar los recursos al terminar cada sesión de práctica** para evitar cargos.

## Requisitos

- Cuenta AWS con usuario IAM (no root) — ver [docs/00-iam-setup.md](docs/00-iam-setup.md)
- AWS CLI v2 instalado
- Región de trabajo: por definir (Amazon Connect no está disponible en todas las regiones)
