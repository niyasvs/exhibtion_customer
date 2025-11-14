# Changelog

## Recent Changes (November 2025)

### QR Code Storage Optimization
**Changed QR code handling to generate on-the-fly instead of storing in database**

#### Modified Files:
1. **`customers/models.py`**
   - ✅ Removed `qr_code` ImageField from Customer model
   - QR codes are no longer stored in the database

2. **`customers/utils.py`**
   - ✅ Updated `generate_qr_code()` to return BytesIO buffer instead of Django File
   - ✅ Updated `send_customer_welcome_email()` to generate and attach QR codes dynamically
   - Removed dependency on file system storage

3. **`customers/admin.py`**
   - ✅ Removed `qr_code_preview` field from readonly_fields
   - ✅ Removed QR Code fieldset from admin interface
   - ✅ Updated `save_model()` to remove QR code saving logic
   - Added description explaining QR codes are generated dynamically

4. **`customers/migrations/0001_initial.py`**
   - ✅ Created initial migration without qr_code field

**Benefits:**
- Reduced database storage requirements
- No file system clutter
- Simplified backup/restore process
- QR codes generated fresh on each email send

---

### Development Environment Setup
**Added comprehensive Docker Compose development setup**

#### New Files Created:

1. **`docker-compose.dev.yml`**
   - Complete development environment with PostgreSQL
   - Django development server with live reload
   - Adminer database GUI
   - Optimized for local development
   - Separate ports to avoid conflicts (5433 for DB, 8000 for web, 8080 for Adminer)

2. **`dev-start.sh`**
   - Automated startup script for development environment
   - Automatically creates .env file if missing
   - Builds containers, runs migrations, creates superuser
   - Shows helpful information about running services

3. **`dev-stop.sh`**
   - Convenient script to stop all development services
   - Shows cleanup instructions

4. **`Makefile`**
   - 40+ convenient commands for development tasks
   - Common operations: start, stop, logs, shell access
   - Database operations: migrate, backup, restore, reset
   - Utility commands: lint, format, check, test
   - Both development and production commands

5. **`DEV_SETUP.md`**
   - Comprehensive development setup guide
   - Quick start instructions
   - Development workflow documentation
   - Troubleshooting guide
   - VS Code integration tips
   - Common commands reference

6. **`DOCKER_ARCHITECTURE.md`**
   - Visual architecture diagrams for all Docker setups
   - Container details and networking
   - Port mappings and volume management
   - Security considerations
   - Environment-specific settings
   - Health check configurations

#### Updated Files:

7. **`README.md`**
   - ✅ Added "Quick Start for Development" section
   - ✅ Updated features to reflect dynamic QR code generation
   - ✅ Added Makefile commands reference
   - ✅ Updated project structure documentation

---

## Docker Compose Environments

### Development (`docker-compose.dev.yml`)
- **Purpose**: Local development
- **Services**: web (Django runserver), db (PostgreSQL), adminer (DB GUI)
- **Ports**: 8000 (web), 5433 (db), 8080 (adminer)
- **Features**: Live reload, debug mode, console emails, exposed ports

### Basic Production (`docker-compose.yml`)
- **Purpose**: Simple production deployment
- **Services**: web (Gunicorn), db (PostgreSQL)
- **Ports**: 8000 (web), 5432 (db)
- **Features**: Gunicorn with 3 workers, health checks

### Full Production (`docker-compose.prod.yml`)
- **Purpose**: Production with reverse proxy and SSL
- **Services**: web (Gunicorn), db (PostgreSQL), nginx, certbot
- **Ports**: 80 (HTTP), 443 (HTTPS)
- **Features**: Nginx reverse proxy, SSL/TLS, 4 workers, auto-restart

---

## Quick Start Commands

### Development
```bash
# Easiest way - automated setup
./dev-start.sh

# Or using Makefile
make dev-start

# Or using docker-compose directly
docker-compose -f docker-compose.dev.yml up
```

### Stop Development
```bash
./dev-stop.sh
# or
make dev-stop
```

### View Logs
```bash
make dev-logs
# or
docker-compose -f docker-compose.dev.yml logs -f
```

### Database Management
```bash
make migrate          # Run migrations
make db-shell         # Open database shell
make backup-db        # Backup database
make reset-db         # Reset database (WARNING: destroys data)
```

### Django Commands
```bash
make django-shell     # Django shell
make makemigrations   # Create migrations
make createsuperuser  # Create admin user
make test             # Run tests
```

---

## Migration Notes

### For Existing Deployments

If upgrading from a version that stored QR codes:

1. **Backup your database first:**
   ```bash
   make backup-db
   ```

2. **Run migrations:**
   ```bash
   docker-compose exec web python manage.py migrate
   ```

3. **Optional - Clean up old QR code files:**
   ```bash
   rm -rf media/qrcodes/
   ```

### For New Deployments

Simply follow the Quick Start guide in README.md or DEV_SETUP.md.

---

## Development Workflow

1. **Start environment:** `./dev-start.sh` or `make dev-start`
2. **Make code changes** - automatically reloaded
3. **View logs:** `make dev-logs`
4. **Access admin:** http://localhost:8000/admin
5. **Manage database:** http://localhost:8080 (Adminer)
6. **Run migrations:** `make migrate`
7. **Stop environment:** `./dev-stop.sh` or `make dev-stop`

---

## Testing

Emails in development are printed to console. Check logs:
```bash
make dev-logs-web
```

Create a test customer in Django admin and verify:
- Customer ID is generated
- Email appears in logs
- QR code is mentioned in email output
- No qr_code field in database

---

## Documentation Structure

```
exhibition_project/
├── README.md              # Main documentation with quick start
├── DEV_SETUP.md          # Detailed development setup guide
├── DOCKER_ARCHITECTURE.md # Docker architecture and details
├── QUICKSTART.md         # Usage guide for the system
├── DEPLOYMENT.md         # Production deployment guide
├── TESTING.md            # Testing guidelines
├── CHANGELOG.md          # This file - change history
└── PROJECT_SUMMARY.md    # Project overview
```

---

## Support

For development issues:
1. Check `DEV_SETUP.md` troubleshooting section
2. View logs: `make dev-logs`
3. Check container status: `make ps`
4. Review `DOCKER_ARCHITECTURE.md` for networking details

For production deployment:
1. Review `DEPLOYMENT.md`
2. Check `docker-compose.prod.yml` configuration
3. Verify environment variables in `.env`

---

## Next Steps

- [ ] Configure email settings for production (SMTP)
- [ ] Set up SSL certificates with Let's Encrypt
- [ ] Configure production domain and ALLOWED_HOSTS
- [ ] Set up automated database backups
- [ ] Configure monitoring and logging
- [ ] Set up CI/CD pipeline (optional)

---

## Version Information

- Django: 4.2.7
- PostgreSQL: 15-alpine
- Python: 3.11-alpine
- Docker Compose: 3.8
- Gunicorn: Latest
- Nginx: Alpine (production only)

