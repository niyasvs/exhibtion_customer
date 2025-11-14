#!/bin/bash

# Exhibition App Setup Script
# This script helps set up the application

set -e

echo "=========================================="
echo "Exhibition Customer Management System"
echo "Setup Script"
echo "=========================================="
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed. Please install Docker first."
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo "Error: Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

echo "✓ Docker and Docker Compose are installed"
echo ""

# Check if .env file exists
if [ ! -f .env ]; then
    echo "Warning: .env file not found."
    echo "Please create a .env file with your configuration."
    echo "You can copy .env.example as a starting point."
    echo ""
    read -p "Do you want to continue anyway? (y/n) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo "Step 1: Building Docker images..."
docker-compose build

echo ""
echo "Step 2: Starting services..."
docker-compose up -d

echo ""
echo "Step 3: Waiting for database to be ready..."
sleep 10

echo ""
echo "Step 4: Running database migrations..."
docker-compose exec web python manage.py migrate

echo ""
echo "Step 5: Creating superuser..."
echo "Please enter your admin credentials:"
docker-compose exec web python manage.py createsuperuser

echo ""
echo "Step 6: Collecting static files..."
docker-compose exec web python manage.py collectstatic --noinput

echo ""
echo "=========================================="
echo "Setup Complete!"
echo "=========================================="
echo ""
echo "Your application is now running at:"
echo "http://localhost:8000/admin"
echo ""
echo "Useful commands:"
echo "  - View logs: docker-compose logs -f"
echo "  - Stop services: docker-compose down"
echo "  - Restart services: docker-compose restart"
echo ""
echo "Happy coding!"

