#!/bin/sh
set -e

: "${POSTGRES_USER:?Environment variable POSTGRES_USER is required}"
: "${POSTGRES_PASSWORD:?Environment variable POSTGRES_PASSWORD is required}"
: "${POSTGRES_HOST:?Environment variable POSTGRES_HOST is required}"
: "${POSTGRES_PORT:?Environment variable POSTGRES_PORT is required}"
: "${POSTGRES_DB:?Environment variable POSTGRES_DB is required}"

# Construct the PostgreSQL DATABASE_URL
export DATABASE_URL="postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@${POSTGRES_HOST}:${POSTGRES_PORT}/${POSTGRES_DB}"

# Run the database initialization script
python create_db.py

exec "$@"