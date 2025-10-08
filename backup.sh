#!/bin/bash

BACKUP_DIR="/opt/db_backups"
DATE=$(date +%F_%H-%M-%S)
DB_USER="root"
DB_PASS="1234"
DB_NAME="backup-db"
S3_BUCKET="s3://anjali-db-backups/db_backups"
echo "Starting backup: $DATE"
mkdir -p $BACKUP_DIR
#echo "Dumping database..."
mysqldump -u $DB_USER -p$DB_PASS $DB_NAME > $BACKUP_DIR/${DB_NAME}_${DATE}.sql
#echo "Removing old backups..."
find $BACKUP_DIR -type f -mtime +7 -name "*.sql" -exec rm {} \;
#echo "Syncing to S3..."
aws s3 sync $BACKUP_DIR $S3_BUCKET
echo "Backup completed at $(date)"
