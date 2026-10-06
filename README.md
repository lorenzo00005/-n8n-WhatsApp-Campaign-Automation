# n8n WhatsApp Campaign Automation

Two n8n workflows that load a contact list into PostgreSQL and send WhatsApp messages from it one contact at a time, rotating across several WhatsApp instances through the Evolution API.

## Workflows

| File | Purpose |
| --- | --- |
| `sqlsave.json` | Ingestion: a form trigger receives an `.xlsx` file, extracts its rows and inserts them into `contactos` with `enviado = false`. |
| `whatsapp_motor_workflow.json` | Dispatcher: a schedule trigger picks one pending contact, chooses the next instance in round-robin order and sends the message. |

## How the dispatcher works

1. A Schedule Trigger runs every minute.
2. `Traer 1 Contacto` selects one contact with `enviado = false` and a valid-looking phone number (non-empty, at least 8 characters).
3. `Traer Todas las Instancias` loads every row of the `instancias` table, and `Obtener Contador Instancia` reads the current position from `workflow_state`.
4. `El Orquestador` (Code node) computes `contador % number_of_instances`, picks that instance and its token, and generates a random delay of 3 to 8 minutes.
5. `Enviar texto` sends the message through the Evolution API node using the selected instance and the delay.
6. `Marcar como Enviado` sets `enviado = true`, and `Actualizar Contador` advances the round-robin counter.

The number of instances is not hardcoded: add or remove rows in `instancias` and the rotation adapts. With N instances and one message per minute, each instance sends at most once every N minutes.

## Required database tables

| Table | Columns |
| --- | --- |
| `contactos` | `id`, `numero` (text), `nombre` (text), `enviado` (boolean) |
| `instancias` | `id`, `nombre_instancia`, `token` |
| `workflow_state` | `id` (single row with `id = 1`), `contador_instancia` (integer) |

## Setup

1. Prepare an n8n instance, a PostgreSQL database (for example Supabase) with the tables above, and an Evolution API server with its instances connected.
2. In n8n, use Import from File for each `.json` in this repository.
3. Re-link the PostgreSQL and Evolution API credentials in every node. All IDs in the files are placeholders (`TU-ID`).
4. In `Enviar texto`, replace the placeholder text `MENSAJE PARA EL BOT` with your message.
5. Upload a spreadsheet with columns `numero` and `nombre` through the ingestion form, then activate the dispatcher workflow.

## Notes

- The schedule node is named "Reloj (Cada 10 min)" but its interval is set to 1 minute. Adjust the interval to match your provider's limits.
- Only send to contacts who have agreed to receive your messages, and follow WhatsApp's terms of use and local regulations on commercial messaging.
- No credentials, tokens or internal addresses are stored in this repository. Use the n8n Credential Manager in production.
