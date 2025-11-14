.PHONY: help dev-start dev-stop dev-restart dev-logs dev-shell db-shell migrate makemigrations createsuperuser test clean

# Development environment commands
DOCKER_COMPOSE = docker-compose -f docker-compose.dev.yml
DOCKER_EXEC = $(DOCKER_COMPOSE) exec web

help: ## Show this help message
	@echo "Exhibition Project - Development Commands"
	@echo "=========================================="
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

dev-start: ## Start development environment
	@echo "🚀 Starting development environment..."
	@./dev-start.sh

dev-stop: ## Stop development environment
	@echo "🛑 Stopping development environment..."
	@$(DOCKER_COMPOSE) down

dev-restart: ## Restart development environment
	@echo "🔄 Restarting development environment..."
	@$(DOCKER_COMPOSE) restart

dev-logs: ## Show logs from all services
	@$(DOCKER_COMPOSE) logs -f

dev-logs-web: ## Show logs from web service only
	@$(DOCKER_COMPOSE) logs -f web

dev-logs-db: ## Show logs from database service only
	@$(DOCKER_COMPOSE) logs -f db

dev-shell: ## Open shell in web container
	@$(DOCKER_EXEC) sh

django-shell: ## Open Django shell
	@$(DOCKER_EXEC) python manage.py shell

db-shell: ## Open database shell
	@$(DOCKER_COMPOSE) exec db psql -U dev_user -d exhibition_db_dev

migrate: ## Run database migrations
	@echo "🔄 Running migrations..."
	@$(DOCKER_EXEC) python manage.py migrate

makemigrations: ## Create new migrations
	@echo "📝 Creating migrations..."
	@$(DOCKER_EXEC) python manage.py makemigrations

showmigrations: ## Show migration status
	@$(DOCKER_EXEC) python manage.py showmigrations

createsuperuser: ## Create a Django superuser
	@$(DOCKER_EXEC) python manage.py createsuperuser

collectstatic: ## Collect static files
	@$(DOCKER_EXEC) python manage.py collectstatic --noinput

test: ## Run tests
	@$(DOCKER_EXEC) python manage.py test

test-coverage: ## Run tests with coverage report
	@$(DOCKER_EXEC) python manage.py test --with-coverage

build: ## Build Docker containers
	@echo "📦 Building containers..."
	@$(DOCKER_COMPOSE) build

rebuild: ## Rebuild Docker containers from scratch
	@echo "📦 Rebuilding containers from scratch..."
	@$(DOCKER_COMPOSE) build --no-cache

ps: ## Show running containers
	@$(DOCKER_COMPOSE) ps

clean: ## Clean up containers and volumes
	@echo "🧹 Cleaning up..."
	@$(DOCKER_COMPOSE) down -v
	@docker system prune -f

reset-db: ## Reset database (WARNING: destroys all data)
	@echo "⚠️  WARNING: This will destroy all database data!"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		$(DOCKER_COMPOSE) down -v; \
		docker volume rm exhibition_project_postgres_dev_data || true; \
		echo "Database reset. Run 'make dev-start' to start fresh."; \
	fi

backup-db: ## Backup database to backups/ directory
	@mkdir -p backups
	@echo "💾 Creating database backup..."
	@$(DOCKER_COMPOSE) exec -T db pg_dump -U dev_user exhibition_db_dev > backups/backup_$$(date +%Y%m%d_%H%M%S).sql
	@echo "✅ Backup created in backups/ directory"

restore-db: ## Restore database from backup (Usage: make restore-db FILE=backups/backup_file.sql)
	@if [ -z "$(FILE)" ]; then \
		echo "❌ Error: Please specify FILE=path/to/backup.sql"; \
		exit 1; \
	fi
	@echo "📥 Restoring database from $(FILE)..."
	@$(DOCKER_COMPOSE) exec -T db psql -U dev_user exhibition_db_dev < $(FILE)
	@echo "✅ Database restored"

lint: ## Run linting checks
	@$(DOCKER_EXEC) flake8 . || true

format: ## Format code with black
	@$(DOCKER_EXEC) black . || true

check: ## Run Django system checks
	@$(DOCKER_EXEC) python manage.py check

urls: ## Show all URL patterns
	@$(DOCKER_EXEC) python manage.py show_urls || echo "Install django-extensions for this feature"

# Production commands
prod-start: ## Start production environment
	@docker-compose -f docker-compose.prod.yml up -d

prod-stop: ## Stop production environment
	@docker-compose -f docker-compose.prod.yml down

prod-logs: ## Show production logs
	@docker-compose -f docker-compose.prod.yml logs -f

prod-build: ## Build production containers
	@docker-compose -f docker-compose.prod.yml build

# Utility commands
install-deps: ## Install Python dependencies
	@$(DOCKER_EXEC) pip install -r requirements.txt

freeze-deps: ## Update requirements.txt with current dependencies
	@$(DOCKER_EXEC) pip freeze > requirements.txt

stats: ## Show container resource usage
	@docker stats --no-stream

