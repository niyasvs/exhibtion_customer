#!/bin/bash

# Development Environment Startup Script
# This script helps you quickly start the development environment

set -e

echo "🚀 Starting Exhibition Project Development Environment"
echo "=================================================="

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Error: Docker is not running. Please start Docker and try again."
    exit 1
fi

# Check if .env file exists
if [ ! -f .env ]; then
    echo "⚠️  No .env file found. Creating from template..."
    cat > .env << 'EOF'
# Development Environment Variables
DEBUG=True
SECRET_KEY=dev-secret-key-change-this-in-production
ALLOWED_HOSTS=localhost,127.0.0.1,0.0.0.0

# Database Configuration
DB_NAME=exhibition_db_dev
DB_USER=dev_user
DB_PASSWORD=dev_pass_123
DB_HOST=db
DB_PORT=5432

# Email Configuration (Console backend for development)
EMAIL_BACKEND=django.core.mail.backends.smtp.EmailBackend
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USE_TLS=True
EMAIL_HOST_USER=neo.sharaf@gmail.com
EMAIL_HOST_PASSWORD=euoxrzuouyirzjng
DEFAULT_FROM_EMAIL=neo.sharaf@gmail.com

# Application URL
APP_URL=http://localhost:8000
EOF
    echo "✅ Created .env file with development defaults"
fi

# Build and start services
echo ""
echo "📦 Building Docker containers..."
docker-compose -f docker-compose.dev.yml build

echo ""
echo "🐳 Starting services..."
docker-compose -f docker-compose.dev.yml up -d

# Wait for database to be ready
echo ""
echo "⏳ Waiting for database to be ready..."
sleep 5

# Run migrations
echo ""
echo "🔄 Running database migrations..."
docker-compose -f docker-compose.dev.yml exec web python manage.py migrate

# Check if superuser exists
echo ""
echo "👤 Checking for superuser..."
if docker-compose -f docker-compose.dev.yml exec web python manage.py shell -c "from django.contrib.auth import get_user_model; User = get_user_model(); exit(0 if User.objects.filter(is_superuser=True).exists() else 1)" 2>/dev/null; then
    echo "✅ Superuser already exists"
else
    echo "📝 Creating superuser..."
    echo "   (You'll be prompted for username, email, and password)"
    docker-compose -f docker-compose.dev.yml exec web python manage.py createsuperuser
fi

# Show running services
echo ""
echo "=================================================="
echo "✅ Development environment is ready!"
echo "=================================================="
echo ""
echo "📍 Services running at:"
echo "   Django Admin:    http://localhost:8000/admin"
echo "   Database GUI:    http://localhost:8080"
echo "                    (Server: db, User: dev_user, Pass: dev_pass_123, DB: exhibition_db_dev)"
echo ""
echo "📋 Useful commands:"
echo "   View logs:       docker-compose -f docker-compose.dev.yml logs -f"
echo "   Stop services:   docker-compose -f docker-compose.dev.yml down"
echo "   Django shell:    docker-compose -f docker-compose.dev.yml exec web python manage.py shell"
echo "   Run migrations:  docker-compose -f docker-compose.dev.yml exec web python manage.py migrate"
echo ""
echo "📖 For more information, see DEV_SETUP.md"
echo ""

# Follow logs
echo "📜 Following logs (Press Ctrl+C to stop viewing logs)..."
echo ""
docker-compose -f docker-compose.dev.yml logs -f

