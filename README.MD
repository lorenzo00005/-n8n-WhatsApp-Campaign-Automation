# n8n WhatsApp Campaign Automation

## 📌 Overview
This repository contains a suite of automated [n8n](https://n8n.io/) workflows designed to manage and execute bulk WhatsApp campaigns efficiently and safely. 

To prevent API bans and ensure high deliverability, this system implements a **Round-Robin Instance Rotation** pattern, distributing the outgoing messages evenly across multiple connected WhatsApp instances (from `Wpp0` to `Wpp9`).

## ⚙️ Architecture

The system is decoupled into three main workflows:

### 1. VCF to Excel Sanitizer (`vcf_cleaner_workflow.json`)
A utility workflow that acts as an endpoint to receive raw `.vcf` (vCard) files, parse them using custom JavaScript, handle encoding anomalies (like UTF-16 null spaces and fragmented line breaks), and output a clean `.xlsx` file containing strict `nombre` and `numero` columns.

### 2. Database Ingestion (`db_ingestion_workflow.json`)
A data-entry pipeline that accepts the cleaned `.xlsx` file via a Webhook/Form trigger, maps the columns, and strictly inserts the contacts into a PostgreSQL/Supabase database table. It initializes each contact with a default `enviado: false` boolean status.

### 3. The Round-Robin Motor (`whatsapp_motor_workflow.json`)
The core cron-based execution engine. 
* **Trigger:** Runs on a scheduled interval (e.g., every 10 minutes).
* **Fetch:** Queries the database for a single uncontacted user (`SELECT * FROM contactos WHERE enviado = false LIMIT 1`).
* **Logic:** Uses `$getWorkflowStaticData` to persist state across executions, calculating the next available WhatsApp instance (0 through 9) in a continuous loop.
* **Execution:** Dispatches the HTTP POST request to the local WhatsApp API gateway, routing it through the dynamically assigned instance.
* **Update:** Flags the user's database record as `enviado: true` to prevent duplicate messaging.

## 🚀 Setup & Installation

1. **Prerequisites:**
   * An active instance of [n8n](https://n8n.io/).
   * A PostgreSQL database (e.g., Supabase) with a `contactos` table (`id`, `Name`, `Telefono`, `enviado` boolean).
   * A WhatsApp API gateway accepting HTTP requests.

2. **Importing Workflows:**
   * Open n8n and click on **Add Workflow**.
   * Select **Import from File** and upload the provided `.json` files.
   * *Note: Credentials have been sanitized. You will need to re-link your PostgreSQL credentials within the nodes upon importing.*

3. **Configuration:**
   * Open the **WhatsApp Motor** workflow.
   * Update the `HTTP Request` node with your actual API endpoint.
   * Adjust the `Schedule Trigger` interval according to your API rate limits and campaign size.

## 🛡️ Security Note
These workflow files have been sanitized. No sensitive API keys, database credentials, or internal IPs are hardcoded in this repository. Ensure you use n8n's built-in Credential Manager for production deployments.