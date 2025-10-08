# aws-database-backup-project

## Automated MariaDB Backup to AWS S3

# MariaDB Backup to AWS S3

This project automatically backs up a MariaDB database from an EC2 instance to an S3 bucket using a bash script and cron.


# Components
1. EC2 Instance – Linux server where MariaDB is installed.
2. MariaDB Database – Database to back up (DB Name: backup-db).
3. S3 Bucket – AWS bucket to store backups (anjali-db-backups).
4. IAM Role – EC2 instance role (s3user) with S3 permissions.
5. Backup Script – Bash script to dump database and sync to S3.
6. Cron Job – Automates daily execution of backup script.


# Step 1: Create Backup Directory
sudo mkdir -p /opt/db_backups
sudo chown ec2-user:ec2-user /opt/db_backups
● Creates a directory to store backups temporarily on EC2.


# Step 2: IAM Role and Permissions
IAM Role: s3user (attached to EC2 instance)
Required Policy:
{
"Version": "2012-10-17",
"Statement": [
{
"Effect": "Allow",
"Action": ["s3:ListBucket"],
"Resource": "arn:aws:s3:::anjali-db-backups"
},
{
"Effect": "Allow",
"Action": ["s3:GetObject","s3:PutObject","s3:DeleteObject"],
"Resource": "arn:aws:s3:::anjali-db-backups/*"
}
]
}
● Gives EC2 permission to list, upload, and delete objects in the S3 bucket. OR add AmazonS3FullAccess permission


# Step 3: Backup Script
Create /opt/db_backups/backup.sh:
#!/bin/bash


BACKUP_DIR="/opt/db_backups"
DATE=$(date +%F_%H-%M-%S)
DB_USER="root"
DB_PASS="1234"
DB_NAME="backup-db"
S3_BUCKET="s3://anjali-db-backups/db_backups"
# echo "Starting backup: $DATE"
mkdir -p $BACKUP_DIR
# echo "Dumping database..."
mysqldump -u $DB_USER -p$DB_PASS $DB_NAME > $BACKUP_DIR/${DB_NAME}_${DATE}.sql
# echo "Removing old backups..."
find $BACKUP_DIR -type f -mtime +7 -name "*.sql" -exec rm {} \;
# echo "Syncing to S3..."
aws s3 sync $BACKUP_DIR $S3_BUCKET
# echo "Backup completed at $(date)"


# Explanation:
● mysqldump: Exports the database to .sql.
● find -mtime +7: Deletes backups older than 7 days.
● aws s3 sync: Uploads all backups to S3.
● echo: Prints a timestamp for logging.


# Make it executable:
chmod +x /opt/db_backups/backup.sh

# Step 4: Test the Script
/opt/db_backups/backup.sh

Verify backups:
ls /opt/db_backups

aws s3 ls s3://anjali-db-backups/db_backups/

● Ensure .sql files appear locally and in S3.


# Step 5: Automate Backups Using Cron
Install Cron (if missing):

● Amazon Linux :
sudo yum install cronie -y
sudo systemctl enable crond
sudo systemctl start crond

Add Cron Job:
sudo crontab -e

Add line:
0 0 * * * /opt/db_backups/backup.sh

● Runs backup daily at midnight automatically.


# Step 6: Verify IAM Role and S3 Access
curl http://169.254.169.254/latest/meta-data/iam/info
aws sts get-caller-identity
aws s3 ls s3://anjali-db-backups/db_backups/

● Confirms EC2 has the correct role and access to S3.

# Summary
1. EC2 instance with MariaDB.
2. IAM role s3user attached.
3. Backup directory /opt/db_backups.
4. Script takes backups, removes old files, syncs to S3.
5. Cron automates daily execution.
6. S3 bucket stores backups securely.



