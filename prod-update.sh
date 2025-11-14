#!/bin/bash

# Production Update Script
# Updates the application in production (for code changes)

set -e

echo "🔄 Exhibition Project - Production Update"
echo "=========================================="
echo ""

# Pull latest code if using git
if [ -d .git ]; then
    echo "📥 Pulling latest code from git..."
    git pull
    echo ""
fi

echo "📦 Rebuilding Docker images..."
docker-compose -f docker-compose.prod.yml build

echo ""
echo "🔄 Running migrations..."
docker-compose -f docker-compose.prod.yml run --rm web python manage.py migrate

echo ""
echo "📁 Collecting static files..."
docker-compose -f docker-compose.prod.yml run --rm web python manage.py collectstatic --noinput

echo ""
echo "♻️  Restarting services..."
docker-compose -f docker-compose.prod.yml up -d

echo ""
echo "⏳ Waiting for services to restart..."
sleep 5

echo ""
echo "✅ Checking service health..."
docker-compose -f docker-compose.prod.yml ps

echo ""
echo "=========================================="
echo "✅ Update complete!"
echo "=========================================="
echo ""
echo "📋 View logs: docker-compose -f docker-compose.prod.yml logs -f"
echo ""

