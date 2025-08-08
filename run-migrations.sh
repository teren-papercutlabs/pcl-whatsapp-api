#!/bin/bash

# Evolution API Migration Runner for v2.3.1
# This script applies the missing migrations to your production database

set -e

echo "================================================"
echo "Evolution API Migration Runner"
echo "================================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

# Check if we're in the right directory
if [ ! -f "package.json" ]; then
    print_error "Error: package.json not found. Please run this script from the pcl-whatsapp-api directory."
    exit 1
fi

echo "This script will apply the following migrations to your PRODUCTION database:"
echo ""
echo "  1. 20250225180031_add_nats_integration"
echo "  2. 20250514232744_add_n8n_table"
echo "  3. 20250515211815_add_evoai_table"
echo "  4. 20250516012152_remove_unique_atribute_for_file_name_in_media"
echo "  5. 20250612155048_add_coluns_trypebot_tables"
echo "  6. 20250613143000_add_lid_column_to_is_onwhatsapp"
echo ""
print_warning "Make sure you have:"
echo "  1. Backed up your database (run production-upgrade-v2.3.1.sh first)"
echo "  2. Updated your code to v2.3.1"
echo "  3. Set DATABASE_CONNECTION_URI in your .env file"
echo ""
read -p "Ready to run migrations? (type 'yes' to proceed): " confirmation

if [ "$confirmation" != "yes" ]; then
    echo "Migrations cancelled."
    exit 1
fi

# Step 1: Generate Prisma Client
echo ""
echo "Step 1: Generating Prisma Client..."
npx prisma generate --schema ./prisma/postgresql-schema.prisma
print_status "Prisma Client generated"

# Step 2: Run migrations
echo ""
echo "Step 2: Applying migrations..."
echo "This will apply all pending migrations to your production database..."

# Check if migrations directory exists
if [ ! -d "./prisma/migrations" ]; then
    echo "Creating migrations directory..."
    cp -r ./prisma/postgresql-migrations ./prisma/migrations
fi

# Deploy migrations
npx prisma migrate deploy --schema ./prisma/postgresql-schema.prisma

print_status "Migrations applied successfully!"

# Step 3: Verify migrations
echo ""
echo "Step 3: Verifying migrations..."
echo "Checking latest migrations in database..."

# You'll need to update this with your actual database credentials
# or set them as environment variables
echo "Please verify the migrations manually with:"
echo "PGPASSWORD=YOUR_PASSWORD psql -h YOUR_HOST -U YOUR_USER -d YOUR_DB -c \"SELECT migration_name FROM _prisma_migrations ORDER BY finished_at DESC LIMIT 10;\""

echo ""
print_status "Migration process completed!"
echo ""
echo "Next steps:"
echo "1. Verify the migrations were applied correctly"
echo "2. Test your application thoroughly"
echo "3. Deploy the updated application code"