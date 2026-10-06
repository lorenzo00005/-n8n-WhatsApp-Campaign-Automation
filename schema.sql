-- Schema for the WhatsApp campaign workflows.
-- Runs automatically on first start when mounted in docker-compose (docker-entrypoint-initdb.d).

CREATE TABLE IF NOT EXISTS contactos (
  id       SERIAL PRIMARY KEY,
  numero   TEXT NOT NULL,
  nombre   TEXT,
  enviado  BOOLEAN NOT NULL DEFAULT FALSE
);

-- Speeds up "pick the next pending contact".
CREATE INDEX IF NOT EXISTS idx_contactos_pendientes
  ON contactos (id) WHERE enviado = FALSE;

-- One row per connected WhatsApp instance (Evolution API).
CREATE TABLE IF NOT EXISTS instancias (
  id                SERIAL PRIMARY KEY,
  nombre_instancia  TEXT NOT NULL UNIQUE,
  token             TEXT NOT NULL
);

-- Single-row table holding the round-robin position.
CREATE TABLE IF NOT EXISTS workflow_state (
  id                  INTEGER PRIMARY KEY,
  contador_instancia  INTEGER NOT NULL DEFAULT 0
);

INSERT INTO workflow_state (id, contador_instancia)
VALUES (1, 0)
ON CONFLICT (id) DO NOTHING;
