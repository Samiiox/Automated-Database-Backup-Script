#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Error: database name required."
    echo "Usage: $0 database_name"
    exit 1
fi

db_name=$1
backup_dir="/opt/oracle/backups"
backup_file="${backup_dir}/${db_name}_$(date +%Y%m%d).tar.gz"
db_dir="/opt/oracle/oradata/ORCLCDB/${db_name}"
extensions=("dbf" "log" "ctl")

if [ ! -d "${db_dir}" ]; then
    echo "Error: database does not exist."
    exit 1
fi

if [ ! -d "${backup_dir}" ]; then
    mkdir "${backup_dir}"
    chmod 700 "${backup_dir}"
fi

files=$(for ext in "${extensions[@]}"; do find "${db_dir}" -name "*.${ext}" -print; done)
total_files=$(echo "${files}" | wc -l)
current_file=0
start_time=$(date +%s)

echo "${files}" | tar czvf "${backup_file}" --files-from=-

if [ $? -eq 0 ]; then
    echo "Database backup completed successfully."
    echo "Backup file created: ${backup_file}"
else
    echo "Error: unable to create database backup."
    exit 1
fi

chmod 600 "${backup_file}"
end_time=$(date +%s)
elapsed_time=$((end_time-start_time))
echo "Total time elapsed: ${elapsed_time} seconds."
