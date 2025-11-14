#!/bin/bash

# Production Deployment Script
# This script helps deploy the Exhibition Project to production

set -e

echo "🚀 Exhibition Project - Production Deployment"
echo "=============================================="
echo ""

# Check if .env file exists
if [ ! -f .env ]; then
    echo "❌ Error: .env file not found!"
    echo ""
    echo "Please create a .env file with production settings."
    echo "See PRODUCTION_SETUP.md for details."
    echo ""
    exit 1
fi

# Check if DEBUG is False
if grep -q "DEBUG=True" .env; then
    echo "⚠️  WARNING: DEBUG=True found in .env"
    echo "   Production should have DEBUG=False"
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo "📦 Building Docker images..."
docker-compose -f docker-compose.prod.yml build

echo ""
echo "🗄️  Starting database..."
docker-compose -f docker-compose.prod.yml up -d db

echo ""
echo "⏳ Waiting for database to be ready..."
sleep 10

echo ""
echo "🔄 Running database migrations..."
docker-compose -f docker-compose.prod.yml run --rm web python manage.py migrate

echo ""
echo "📁 Collecting static files..."
docker-compose -f docker-compose.prod.yml run --rm web python manage.py collectstatic --noinput

echo ""
echo "🌐 Starting all services..."
docker-compose -f docker-compose.prod.yml up -d

echo ""
echo "⏳ Waiting for services to start..."
sleep 5

echo ""
echo "✅ Checking service health..."
docker-compose -f docker-compose.prod.yml ps

echo ""
echo "=============================================="
echo "✅ Deployment complete!"
echo "=============================================="
echo ""
echo "📍 Your application should be accessible at:"
echo "   - Admin: http://your-domain.com/admin"
echo ""
echo "📋 Useful commands:"
echo "   View logs:       docker-compose -f docker-compose.prod.yml logs -f"
echo "   Stop services:   docker-compose -f docker-compose.prod.yml down"
echo "   Restart:         docker-compose -f docker-compose.prod.yml restart"
echo ""
echo "📖 For more information, see PRODUCTION_SETUP.md"
echo ""

