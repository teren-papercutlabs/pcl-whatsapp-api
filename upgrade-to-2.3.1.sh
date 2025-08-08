#!/bin/bash

# Evolution API Upgrade Script - v2.2.3 to v2.3.1
# This script helps upgrade your Evolution API installation

set -e

echo "================================================"
echo "Evolution API Upgrade: v2.2.3 → v2.3.1"
echo "================================================"
echo ""

# Configuration
BACKUP_DIR="./backups/$(date +%Y%m%d_%H%M%S)"
DB_CONTAINER="postgres"
DB_NAME="evolution"
DB_USER="user"

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

# Step 1: Create backup directory
echo "Step 1: Creating backup directory..."
mkdir -p "$BACKUP_DIR"
print_status "Backup directory created: $BACKUP_DIR"

# Step 2: Backup database
echo ""
echo "Step 2: Backing up database..."
if docker ps | grep -q $DB_CONTAINER; then
    docker exec $DB_CONTAINER pg_dump -U $DB_USER $DB_NAME > "$BACKUP_DIR/database_backup.sql"
    print_status "Database backed up to: $BACKUP_DIR/database_backup.sql"
else
    print_warning "Database container not running. Skipping database backup."
    echo "If you have a remote database, please backup manually."
fi

# Step 3: Backup current code
echo ""
echo "Step 3: Backing up current code..."
cp -r ./src "$BACKUP_DIR/src_backup" 2>/dev/null || true
cp ./package.json "$BACKUP_DIR/package.json.backup" 2>/dev/null || true
cp ./Dockerfile "$BACKUP_DIR/Dockerfile.backup" 2>/dev/null || true
print_status "Code backed up to: $BACKUP_DIR"

# Step 4: Check current migration status
echo ""
echo "Step 4: Checking current migration status..."
if docker ps | grep -q $DB_CONTAINER; then
    echo "Current migrations in database:"
    docker exec $DB_CONTAINER psql -U $DB_USER -d $DB_NAME -c "SELECT migration_name FROM _prisma_migrations ORDER BY finished_at DESC LIMIT 10;" || true
else
    print_warning "Cannot check migration status - database container not running"
fi

echo ""
print_warning "BACKUP COMPLETE!"
echo ""
echo "Next steps to complete the upgrade:"
echo "1. Stop the current Evolution API: docker-compose down"
echo "2. Copy new code from evolution-api-latest to this directory"
echo "3. Update Dockerfile to use: RUN npm install --legacy-peer-deps"
echo "4. Run database migrations (see migrate.sh)"
echo "5. Rebuild and start: docker-compose up --build -d"
echo ""
echo "To restore if needed:"
echo "  - Database: docker exec -i $DB_CONTAINER psql -U $DB_USER $DB_NAME < $BACKUP_DIR/database_backup.sql"
echo "  - Code: cp -r $BACKUP_DIR/src_backup ./src"
echo ""
print_status "Backup script completed successfully!"