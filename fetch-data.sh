#!/bin/bash

# Install PostgreSQL client tools (only needed if not already installed)
# sudo apt-get install postgresql-client

# Production database credentials
production_db_host="xxx.rds.amazonaws.com"
production_db_name="xxx"
production_db_user="postgres"
production_db_password="xxx"

# Local database credentials
local_db_host="localhost"
local_db_name="dbservice_dev"
local_db_user="postgres"
local_db_password="postgres"

# Dump file name
dump_file="dump.sql"

# Determine the path of pg_dump and psql using the which command
pg_dump_path=$(which pg_dump)  # retrieves the path of the pg_dump executable
psql_path=$(which psql)        # retrieves the path of the psql executable

# Check if PostgreSQL client tools are installed
if [ -z "$pg_dump_path" ] || [ -z "$psql_path" ]; then
  echo "Error: PostgreSQL client tools not found on this system"
  exit 1
fi

# Fetch the data dump from the production database
echo "Fetching data dump from production database..."
PGPASSWORD="$production_db_password" "$pg_dump_path" --host="$production_db_host" --port=5432 --username="$production_db_user" --dbname="$production_db_name" --file="$dump_file"
if [ $? -ne 0 ]; then
  echo "Error: Failed to fetch data dump from production database"
  exit 1
fi

# Restore the dump file to the local database
echo "Restoring data dump to local database..."
PGPASSWORD="$local_db_password" "$psql_path" --host="$local_db_host" --port=5432 --username="$local_db_user" --dbname="$local_db_name" --file="$dump_file"
if [ $? -ne 0 ]; then
  echo "Error: Failed to restore data dump to local database"
  exit 1
fi

# Remove the dump file
echo "Cleaning up..."
rm "$dump_file"
echo "Database restored successfully."
