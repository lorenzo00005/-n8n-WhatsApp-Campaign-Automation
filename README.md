# -n8n-WhatsApp-Campaign-Automation

Scalable n8n automation system for high-volume WhatsApp campaigns. Features robust VCF sanitization, secure encrypted XLSX data ingestion into PostgreSQL, and a high-performance **15-instance Round-Robin message dispatcher** designed to distribute network load and eliminate API ban risks.

## ⚙️ Core Specifications & Features

* **15-Instance Load Balancing:** Fully scaled to cycle dynamically through 15 parallel WhatsApp instances (from `Wpp0` to `Wpp14`) to distribute the message volume evenly.
* **Intelligent Rate Limiting:** Configured with a strict **1-minute cron trigger**. By cycling sequentially through all 15 instances, the system automatically guarantees a safe **15-minute cool-down window** between messages for any individual phone number.
* **Secure Ingestion Pipeline:** Implements a specialized encryption node during the XLSX parsing stage, ensuring that sensitive contact spreadsheets are protected and securely handled before being committed to the PostgreSQL database.
* **Database-Driven State Management:** Fully integrated with PostgreSQL/Supabase to track message delivery status dynamically and prevent duplicate entries.
