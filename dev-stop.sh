#!/bin/bash

# Development Environment Stop Script
# This script stops all development services

set -e

echo "🛑 Stopping Exhibition Project Development Environment"
echo "=================================================="

# Stop services
docker-compose -f docker-compose.dev.yml down

echo ""
echo "✅ All services stopped successfully!"
echo ""
echo "📋 To start again, run: ./dev-start.sh"
echo "📋 To remove database volume: docker volume rm exhibition_project_postgres_dev_data"
echo ""

