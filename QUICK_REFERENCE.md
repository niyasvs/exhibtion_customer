# Quick Reference Card

## 🚀 Getting Started

```bash
./dev-start.sh                    # Start everything
```

**Access Points:**
- Admin: http://localhost:8000/admin
- Database GUI: http://localhost:8080

```bash
./dev-stop.sh                     # Stop everything
```

---

## 📦 Common Make Commands

### Environment
```bash
make help                # Show all commands
make dev-start          # Start development
make dev-stop           # Stop development
make dev-restart        # Restart services
make dev-logs           # View all logs
make dev-logs-web       # View web logs only
```

### Shell Access
```bash
make dev-shell          # Container shell
make django-shell       # Django Python shell
make db-shell           # PostgreSQL shell
```

### Database
```bash
make migrate            # Apply migrations
make makemigrations     # Create migrations
make backup-db          # Backup database
make reset-db           # Reset database (⚠️ DESTRUCTIVE)
```

### Django
```bash
make createsuperuser    # Create admin user
make collectstatic      # Collect static files
make test               # Run tests
make check              # System checks
```

---

## 🐳 Docker Compose Commands

### Development
```bash
# Full command format
docker-compose -f docker-compose.dev.yml [command]

# Examples
docker-compose -f docker-compose.dev.yml up          # Start
docker-compose -f docker-compose.dev.yml up -d       # Start detached
docker-compose -f docker-compose.dev.yml down        # Stop
docker-compose -f docker-compose.dev.yml logs -f     # Follow logs
docker-compose -f docker-compose.dev.yml ps          # List containers
docker-compose -f docker-compose.dev.yml restart     # Restart
docker-compose -f docker-compose.dev.yml build       # Rebuild
```

### Execute Commands in Container
```bash
docker-compose -f docker-compose.dev.yml exec web [command]

# Examples
docker-compose -f docker-compose.dev.yml exec web python manage.py migrate
docker-compose -f docker-compose.dev.yml exec web python manage.py shell
docker-compose -f docker-compose.dev.yml exec web sh
```

---

## 🗄️ Database Operations

### Connect to Database
```bash
# Using Adminer GUI
# Browser: http://localhost:8080
# System: PostgreSQL
# Server: db
# User: dev_user
# Password: dev_pass_123
# Database: exhibition_db_dev

# Using psql (in container)
make db-shell

# Using psql (from host, if installed)
psql -h localhost -p 5433 -U dev_user -d exhibition_db_dev
```

### Backup & Restore
```bash
# Backup
make backup-db
# Creates: backups/backup_YYYYMMDD_HHMMSS.sql

# Restore
make restore-db FILE=backups/backup_file.sql

# Manual backup
docker-compose -f docker-compose.dev.yml exec -T db \
  pg_dump -U dev_user exhibition_db_dev > backup.sql

# Manual restore
docker-compose -f docker-compose.dev.yml exec -T db \
  psql -U dev_user exhibition_db_dev < backup.sql
```

---

## 📝 Django Management Commands

All commands run inside the web container:

```bash
# Using Make (recommended)
make [command]

# Or directly
docker-compose -f docker-compose.dev.yml exec web python manage.py [command]
```

### Common Commands
```bash
migrate                           # Apply migrations
makemigrations                   # Create migrations
makemigrations customers         # Create for specific app
showmigrations                   # Show migration status
createsuperuser                  # Create admin user
changepassword username          # Change user password
shell                           # Python shell with Django
dbshell                         # Database shell
check                           # System check
test                            # Run tests
test customers                  # Test specific app
collectstatic                   # Collect static files
runserver 0.0.0.0:8000         # Run dev server (already running)
```

---

## 📊 Monitoring & Debugging

### View Logs
```bash
# All services
make dev-logs

# Specific service
docker-compose -f docker-compose.dev.yml logs -f web
docker-compose -f docker-compose.dev.yml logs -f db
docker-compose -f docker-compose.dev.yml logs -f adminer

# Last 50 lines
docker-compose -f docker-compose.dev.yml logs --tail=50 web

# Since specific time
docker-compose -f docker-compose.dev.yml logs --since 10m web
```

### Container Status
```bash
# List containers
make ps
docker-compose -f docker-compose.dev.yml ps

# Resource usage
make stats
docker stats --no-stream

# Inspect container
docker inspect exhibition_web_dev
```

### Health Checks
```bash
# Check database
docker-compose -f docker-compose.dev.yml exec db pg_isready -U dev_user

# Check web server
curl http://localhost:8000/admin/
```

---

## 🔧 Troubleshooting

### Port Already in Use
```bash
# Find process using port
lsof -ti:8000           # Web
lsof -ti:5433           # Database
lsof -ti:8080           # Adminer

# Kill process
lsof -ti:8000 | xargs kill -9
```

### Container Won't Start
```bash
# View logs
docker-compose -f docker-compose.dev.yml logs

# Check status
docker-compose -f docker-compose.dev.yml ps

# Rebuild from scratch
docker-compose -f docker-compose.dev.yml build --no-cache
docker-compose -f docker-compose.dev.yml up
```

### Database Connection Issues
```bash
# Wait for database health check
docker-compose -f docker-compose.dev.yml ps

# Restart services
docker-compose -f docker-compose.dev.yml restart

# Check environment variables
docker-compose -f docker-compose.dev.yml exec web env | grep DB_
```

### Reset Everything
```bash
# Stop and remove everything
make clean

# Or manually
docker-compose -f docker-compose.dev.yml down -v
docker volume rm exhibition_project_postgres_dev_data
docker system prune -f

# Start fresh
./dev-start.sh
```

---

## 🎯 File Locations

### Configuration
```
.env                              # Environment variables
docker-compose.dev.yml           # Dev Docker config
docker-compose.yml               # Basic prod config
docker-compose.prod.yml          # Full prod config
Dockerfile                       # Container definition
requirements.txt                 # Python dependencies
```

### Application
```
exhibition_project/settings.py   # Django settings
exhibition_project/urls.py       # URL routing
customers/models.py              # Database models
customers/admin.py               # Admin interface
customers/utils.py               # QR & email utilities
customers/migrations/            # Database migrations
```

### Development Scripts
```
dev-start.sh                     # Start dev environment
dev-stop.sh                      # Stop dev environment
Makefile                         # Make commands
```

### Documentation
```
README.md                        # Main documentation
DEV_SETUP.md                     # Development setup
DOCKER_ARCHITECTURE.md           # Docker details
DEPLOYMENT.md                    # Production deployment
CHANGELOG.md                     # Change history
QUICK_REFERENCE.md               # This file
```

---

## 🔐 Default Credentials

### Development Database
```
Host: localhost
Port: 5433
Database: exhibition_db_dev
User: dev_user
Password: dev_pass_123
```

### Adminer
```
URL: http://localhost:8080
System: PostgreSQL
Server: db
Username: dev_user
Password: dev_pass_123
Database: exhibition_db_dev
```

### Django Admin
```
URL: http://localhost:8000/admin
Username: (create with make createsuperuser)
Password: (set during creation)
```

---

## 🌐 URLs

### Development
```
Admin Interface:     http://localhost:8000/admin
Database GUI:        http://localhost:8080
API (if enabled):    http://localhost:8000/api/
```

### Production
```
Website:            https://yourdomain.com
Admin:              https://yourdomain.com/admin
```

---

## 📚 Quick Tips

1. **Code Changes**: Auto-reload in development - just save and refresh!

2. **Email Testing**: Emails print to console in dev mode
   ```bash
   make dev-logs-web
   ```

3. **Database GUI**: Use Adminer at http://localhost:8080 for easy DB browsing

4. **Python Packages**: After adding to requirements.txt:
   ```bash
   docker-compose -f docker-compose.dev.yml build
   docker-compose -f docker-compose.dev.yml up
   ```

5. **Migration Workflow**:
   ```bash
   make makemigrations    # Create migration
   make migrate           # Apply migration
   ```

6. **Fresh Start**:
   ```bash
   make reset-db          # Reset database
   make dev-restart       # Restart services
   ```

7. **View All Commands**:
   ```bash
   make help
   ```

---

## 🆘 Need Help?

- **Development Setup**: See `DEV_SETUP.md`
- **Docker Details**: See `DOCKER_ARCHITECTURE.md`
- **System Usage**: See `QUICKSTART.md`
- **Deployment**: See `DEPLOYMENT.md`
- **Changes**: See `CHANGELOG.md`

---

## 📞 Support Checklist

Before asking for help:
1. ✅ Check logs: `make dev-logs`
2. ✅ Verify containers running: `make ps`
3. ✅ Check database health: `docker-compose -f docker-compose.dev.yml ps`
4. ✅ Review environment variables: `cat .env`
5. ✅ Try restarting: `make dev-restart`
6. ✅ Check troubleshooting section in `DEV_SETUP.md`

---

**Print this page and keep it handy! 📌**

