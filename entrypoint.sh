#!/bin/sh
set -eu

if [ -z "${DATABASE_URL:-}" ]; then
    echo "DATABASE_URL no está configurada." >&2
    exit 1
fi

export PGCONNECT_TIMEOUT=10
until psql "$DATABASE_URL" -Atqc 'SELECT 1' >/dev/null 2>&1; do
    echo "Esperando PostgreSQL..."
    sleep 3
done

if [ "$(psql "$DATABASE_URL" -Atqc "SELECT to_regclass('public.afiliado') IS NOT NULL")" != "t" ]; then
    echo "Inicializando esquema y datos de demostración..."
    psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f /opt/proyecto.sql
fi

exec apache2-foreground
