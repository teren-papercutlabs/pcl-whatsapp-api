#!/bin/bash

# Evolution API Production Upgrade Script - v2.2.3 to v2.3.1
# PRODUCTION DATABASE - Handle with care!

set -e

echo "================================================"
echo "Evolution API PRODUCTION Upgrade: v2.2.3 → v2.3.1"
echo "================================================"
echo ""

# Production Database Configuration
DB_HOST="dpg-d154dovfte5s738phpb0-a.singapore-postgres.render.com"
DB_USER="weaver_whatsapp_db_user"
DB_NAME="weaver_whatsapp_db"
DB_PASSWORD="ZcjD7eotRrblihBDA0m56AM0QuZszqWB"

# Backup Configuration
BACKUP_DIR="./backups/production_$(date +%Y%m%d_%H%M%S)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

echo "⚠️  PRODUCTION DATABASE WARNING ⚠️"
echo "This script will modify your PRODUCTION database at:"
echo "Host: $DB_HOST"
echo "Database: $DB_NAME"
echo ""
read -p "Are you sure you want to continue? (type 'yes' to proceed): " confirmation

if [ "$confirmation" != "yes" ]; then
    echo "Upgrade cancelled."
    exit 1
fi

# Step 1: Create backup directory
echo ""
echo "Step 1: Creating backup directory..."
mkdir -p "$BACKUP_DIR"
print_status "Backup directory created: $BACKUP_DIR"

# Step 2: Backup production database
echo ""
echo "Step 2: Backing up PRODUCTION database..."
echo "This may take a while depending on database size..."
PGPASSWORD=$DB_PASSWORD pg_dump -h $DB_HOST -U $DB_USER -d $DB_NAME > "$BACKUP_DIR/production_database_backup.sql"
print_status "Production database backed up to: $BACKUP_DIR/production_database_backup.sql"

# Step 3: Verify backup
echo ""
echo "Step 3: Verifying backup..."
BACKUP_SIZE=$(ls -lh "$BACKUP_DIR/production_database_backup.sql" | awk '{print $5}')
print_status "Backup file size: $BACKUP_SIZE"

# Step 4: Check current migration status
echo ""
echo "Step 4: Checking current migration status..."
echo "Last 5 migrations in production:"
PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -U $DB_USER -d $DB_NAME -c "SELECT migration_name, finished_at FROM _prisma_migrations ORDER BY finished_at DESC LIMIT 5;"

echo ""
print_warning "BACKUP COMPLETE! Database backup saved to:"
echo "  $BACKUP_DIR/production_database_backup.sql"
echo ""
echo "===== NEXT STEPS ====="
echo ""
echo "1. Update your code:"
echo "   cp -r ../evolution-api-latest/* ./"
echo ""
echo "2. Fix the Docker dependency issue in Dockerfile:"
echo "   Change: RUN npm install"
echo "   To:     RUN npm install --legacy-peer-deps"
echo ""
echo "3. Update your .env file with production database URL:"
echo "   DATABASE_CONNECTION_URI='postgresql://$DB_USER:$DB_PASSWORD@$DB_HOST:5432/$DB_NAME?schema=public'"
echo ""
echo "4. Run the migrations using the migration script (run-migrations.sh)"
echo ""
echo "5. Deploy your updated application"
echo ""
print_warning "TO RESTORE DATABASE IF NEEDED:"
echo "  PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -U $DB_USER -d $DB_NAME < $BACKUP_DIR/production_database_backup.sql"
echo ""
print_status "Backup phase completed successfully!"