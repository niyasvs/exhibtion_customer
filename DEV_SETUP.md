# Development Setup Guide

This guide will help you set up the Exhibition Customer Management System for local development using Docker Compose.

## Prerequisites

- Docker (20.10 or later)
- Docker Compose (2.0 or later)
- Git

## Quick Start

### 1. Clone the Repository

```bash
git clone <repository-url>
cd exhibition_project
```

### 2. Setup Environment Variables

Copy the development environment file:

```bash
cp .env.dev .env
```

Or create your own `.env` file with the following configuration:

```env
DEBUG=True
SECRET_KEY=dev-secret-key-change-this
ALLOWED_HOSTS=localhost,127.0.0.1

DB_NAME=exhibition_db_dev
DB_USER=dev_user
DB_PASSWORD=dev_pass_123
DB_HOST=db
DB_PORT=5432

EMAIL_BACKEND=django.core.mail.backends.smtp.EmailBackend
```

### 3. Build and Start Services

```bash
docker-compose -f docker-compose.dev.yml up --build
```

This will:
- Start a PostgreSQL database on port 5433
- Start Django development server on port 8000
- Start Adminer (database GUI) on port 8080

### 4. Run Migrations

In a new terminal, run:

```bash
docker-compose -f docker-compose.dev.yml exec web python manage.py migrate
```

### 5. Create a Superuser

```bash
docker-compose -f docker-compose.dev.yml exec web python manage.py createsuperuser
```

### 6. Access the Application

- **Django Admin**: http://localhost:8000/admin
- **Adminer (DB GUI)**: http://localhost:8080
  - System: `PostgreSQL`
  - Server: `db`
  - Username: `dev_user`
  - Password: `dev_pass_123`
  - Database: `exhibition_db_dev`

## Development Workflow

### Starting the Services

```bash
docker-compose -f docker-compose.dev.yml up
```

Or run in detached mode:

```bash
docker-compose -f docker-compose.dev.yml up -d
```

### Stopping the Services

```bash
docker-compose -f docker-compose.dev.yml down
```

### Viewing Logs

```bash
# All services
docker-compose -f docker-compose.dev.yml logs -f

# Specific service
docker-compose -f docker-compose.dev.yml logs -f web
docker-compose -f docker-compose.dev.yml logs -f db
```

### Running Django Commands

```bash
# Make migrations
docker-compose -f docker-compose.dev.yml exec web python manage.py makemigrations

# Apply migrations
docker-compose -f docker-compose.dev.yml exec web python manage.py migrate

# Create superuser
docker-compose -f docker-compose.dev.yml exec web python manage.py createsuperuser

# Collect static files
docker-compose -f docker-compose.dev.yml exec web python manage.py collectstatic --noinput

# Django shell
docker-compose -f docker-compose.dev.yml exec web python manage.py shell
```

### Accessing the Container Shell

```bash
docker-compose -f docker-compose.dev.yml exec web sh
```

### Accessing the Database

Using Adminer GUI: http://localhost:8080

Or using psql command line:

```bash
docker-compose -f docker-compose.dev.yml exec db psql -U dev_user -d exhibition_db_dev
```

From your host machine (if you have psql installed):

```bash
psql -h localhost -p 5433 -U dev_user -d exhibition_db_dev
```

## Code Changes

The entire project directory is mounted as a volume in the container, so any changes you make to the code will be immediately reflected without needing to rebuild the container. The Django development server automatically reloads when it detects file changes.

## Email Testing

The development environment uses Django's console email backend, which prints emails to the console instead of sending them. You'll see email output in the logs:

```bash
docker-compose -f docker-compose.dev.yml logs -f web
```

## Database Management

### Resetting the Database

To completely reset your development database:

```bash
# Stop services
docker-compose -f docker-compose.dev.yml down

# Remove database volume
docker volume rm exhibition_project_postgres_dev_data

# Start services and run migrations
docker-compose -f docker-compose.dev.yml up -d
docker-compose -f docker-compose.dev.yml exec web python manage.py migrate
docker-compose -f docker-compose.dev.yml exec web python manage.py createsuperuser
```

### Backing Up the Database

```bash
docker-compose -f docker-compose.dev.yml exec db pg_dump -U dev_user exhibition_db_dev > backup.sql
```

### Restoring a Database Backup

```bash
docker-compose -f docker-compose.dev.yml exec -T db psql -U dev_user exhibition_db_dev < backup.sql
```

## Troubleshooting

### Port Already in Use

If you get "port already in use" errors:

**Port 8000 (Django):**
```bash
# Find and kill process using port 8000
lsof -ti:8000 | xargs kill -9
```

**Port 5433 (PostgreSQL):**
```bash
# Find and kill process using port 5433
lsof -ti:5433 | xargs kill -9
```

Or change the port mappings in `docker-compose.dev.yml`.

### Database Connection Issues

If the web service can't connect to the database:

```bash
# Check database health
docker-compose -f docker-compose.dev.yml ps

# View database logs
docker-compose -f docker-compose.dev.yml logs db

# Restart services
docker-compose -f docker-compose.dev.yml restart
```

### Module Not Found Errors

If you get "ModuleNotFoundError":

```bash
# Rebuild the containers
docker-compose -f docker-compose.dev.yml up --build
```

### Container Keeps Restarting

Check the logs for errors:

```bash
docker-compose -f docker-compose.dev.yml logs web
```

Common issues:
- Database not ready: Wait for health check to pass
- Migration errors: Run migrations manually
- Port conflicts: Check if ports are already in use

## Development Tools

### Adminer (Database GUI)

Access at http://localhost:8080

Features:
- Browse tables and data
- Execute SQL queries
- Import/export data
- Manage database schema

### Django Debug Toolbar (Optional)

To add Django Debug Toolbar for development:

1. Add to requirements.txt:
   ```
   django-debug-toolbar==4.2.0
   ```

2. Update settings.py:
   ```python
   if DEBUG:
       INSTALLED_APPS += ['debug_toolbar']
       MIDDLEWARE += ['debug_toolbar.middleware.DebugToolbarMiddleware']
       INTERNAL_IPS = ['127.0.0.1', 'localhost']
   ```

3. Rebuild containers:
   ```bash
   docker-compose -f docker-compose.dev.yml up --build
   ```

## VS Code Integration

For the best development experience with VS Code:

1. Install the "Remote - Containers" extension
2. Open the project in VS Code
3. Press F1 and select "Remote-Containers: Attach to Running Container"
4. Select the `exhibition_web_dev` container

This allows you to:
- Use VS Code's debugger inside the container
- Run commands in the integrated terminal
- Get IntelliSense for installed packages

## Next Steps

- Read [QUICKSTART.md](QUICKSTART.md) for system usage
- Read [TESTING.md](TESTING.md) for testing guidelines
- Read [DEPLOYMENT.md](DEPLOYMENT.md) for production deployment

## Differences from Production

| Feature | Development | Production |
|---------|------------|------------|
| Web Server | Django runserver | Gunicorn + Nginx |
| Debug Mode | Enabled | Disabled |
| Email | Console output | SMTP server |
| Database | Local volume | Persistent volume |
| Static Files | Served by Django | Served by Nginx |
| SSL/HTTPS | Not configured | Let's Encrypt |
| Port | 8000 | 80/443 |

## Support

For issues or questions:
1. Check the logs: `docker-compose -f docker-compose.dev.yml logs`
2. Review the documentation
3. Contact the development team

