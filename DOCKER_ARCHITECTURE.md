# Docker Architecture Overview

This document explains the Docker setup for the Exhibition Customer Management System.

## Docker Compose Files

The project has three Docker Compose configurations:

### 1. `docker-compose.dev.yml` - Development Environment
**Purpose**: Local development with live code reloading

```
┌─────────────────────────────────────────────────────────┐
│                  Development Environment                 │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  ┌──────────────┐      ┌──────────────┐      ┌────────┐│
│  │              │      │              │      │        ││
│  │   Adminer    │◄─────┤  PostgreSQL  │◄─────┤  Web   ││
│  │   (GUI)      │      │  Database    │      │ Django ││
│  │              │      │              │      │        ││
│  │  Port: 8080  │      │  Port: 5433  │      │  8000  ││
│  └──────────────┘      └──────────────┘      └────────┘│
│                                                          │
│  Volume Mounts:                                          │
│  • /app (code) - Live reload                            │
│  • postgres_dev_data (database)                         │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

**Services**:
- **web**: Django development server (runserver)
- **db**: PostgreSQL 15 (port 5433 on host)
- **adminer**: Database GUI (port 8080)

**Features**:
- Live code reloading
- Console email backend (emails print to logs)
- Debug mode enabled
- Direct volume mounting for quick development
- Exposed ports for easy access

### 2. `docker-compose.yml` - Basic Production
**Purpose**: Simple production deployment without Nginx

```
┌─────────────────────────────────────────────┐
│         Basic Production Environment        │
├─────────────────────────────────────────────┤
│                                             │
│  ┌──────────────┐      ┌──────────────┐    │
│  │              │      │              │    │
│  │  PostgreSQL  │◄─────┤     Web      │    │
│  │  Database    │      │  (Gunicorn)  │    │
│  │              │      │              │    │
│  │  Port: 5432  │      │  Port: 8000  │    │
│  └──────────────┘      └──────────────┘    │
│                                             │
│  Volumes:                                   │
│  • postgres_data                            │
│  • static_volume                            │
│  • media_volume                             │
│                                             │
└─────────────────────────────────────────────┘
```

**Services**:
- **web**: Gunicorn with 3 workers
- **db**: PostgreSQL 15 with health checks

### 3. `docker-compose.prod.yml` - Full Production
**Purpose**: Production-ready with Nginx and SSL

```
┌──────────────────────────────────────────────────────────────┐
│              Full Production Environment                      │
├──────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────┐     ┌──────────┐     ┌─────────┐     ┌──────┐│
│  │          │     │          │     │         │     │      ││
│  │ Internet │────►│  Nginx   │────►│   Web   │────►│  DB  ││
│  │          │     │(Reverse  │     │(Gunicorn│     │      ││
│  │          │     │  Proxy)  │     │ 4 wrkrs)│     │      ││
│  │  80/443  │     │  Port 80 │     │         │     │      ││
│  └──────────┘     │  Port 443│     └─────────┘     └──────┘│
│                   └─────┬────┘                              │
│                         │                                    │
│                         ▼                                    │
│                   ┌──────────┐                              │
│                   │ Certbot  │                              │
│                   │(SSL/TLS) │                              │
│                   └──────────┘                              │
│                                                               │
│  Networks: backend                                            │
│  Volumes: postgres_data, static_volume, media_volume         │
│                                                               │
└──────────────────────────────────────────────────────────────┘
```

**Services**:
- **web**: Gunicorn with 4 workers
- **db**: PostgreSQL 15 with backups
- **nginx**: Reverse proxy with SSL
- **certbot**: Automatic SSL certificate renewal

## Container Details

### Web Container (Django)

**Base Image**: `python:3.11-alpine`

**Structure**:
```
/app/
├── exhibition_project/   # Django settings
├── customers/            # Customer app
├── manage.py
├── requirements.txt
├── media/               # User uploads
└── staticfiles/         # Collected static files
```

**Environment Variables**:
- `DEBUG`: Enable/disable debug mode
- `DB_HOST`: Database hostname (usually 'db')
- `DB_NAME`: Database name
- `DB_USER`: Database user
- `DB_PASSWORD`: Database password
- `EMAIL_BACKEND`: Email backend to use
- `SECRET_KEY`: Django secret key

### Database Container (PostgreSQL)

**Base Image**: `postgres:15-alpine`

**Default Credentials** (Development):
- Database: `exhibition_db_dev`
- User: `dev_user`
- Password: `dev_pass_123`

**Data Persistence**:
- Development: `postgres_dev_data` volume
- Production: `postgres_data` volume

**Health Check**:
```bash
pg_isready -U {username} -d {database}
```

## Networking

### Development
- **Network**: `dev_network` (bridge)
- **Internal communication**: Service names (web, db, adminer)
- **External access**: Via published ports

### Production
- **Network**: `backend` (bridge)
- **Internal communication**: Service names only
- **External access**: Via Nginx on ports 80/443

## Volumes and Data Persistence

### Development Volumes
```
postgres_dev_data     → /var/lib/postgresql/data  (Database data)
./                    → /app                       (Live code)
```

### Production Volumes
```
postgres_data         → /var/lib/postgresql/data  (Database data)
static_volume         → /app/staticfiles          (Static files)
media_volume          → /app/media                (Media files)
./nginx/              → /etc/nginx/               (Nginx config)
./certbot/            → /etc/letsencrypt/         (SSL certs)
```

## Port Mappings

### Development (`docker-compose.dev.yml`)
| Service | Container Port | Host Port | Purpose          |
|---------|---------------|-----------|------------------|
| web     | 8000          | 8000      | Django dev server|
| db      | 5432          | 5433      | PostgreSQL       |
| adminer | 8080          | 8080      | Database GUI     |

### Basic Production (`docker-compose.yml`)
| Service | Container Port | Host Port | Purpose          |
|---------|---------------|-----------|------------------|
| web     | 8000          | 8000      | Gunicorn         |
| db      | 5432          | 5432      | PostgreSQL       |

### Full Production (`docker-compose.prod.yml`)
| Service | Container Port | Host Port | Purpose          |
|---------|---------------|-----------|------------------|
| nginx   | 80            | 80        | HTTP             |
| nginx   | 443           | 443       | HTTPS            |
| web     | 8000          | -         | Internal only    |
| db      | 5432          | -         | Internal only    |

## Health Checks

### Database Health Check
```yaml
healthcheck:
  test: ["CMD-SHELL", "pg_isready -U {user} -d {database}"]
  interval: 5-10s
  timeout: 3-5s
  retries: 5
```

### Web Health Check (Production)
```yaml
healthcheck:
  test: ["CMD-SHELL", "curl -f http://localhost:8000/admin/ || exit 1"]
  interval: 30s
  timeout: 10s
  retries: 3
  start_period: 40s
```

## Environment-Specific Settings

### Development
- Django `runserver` (auto-reloads on code changes)
- DEBUG=True
- Console email backend
- Direct volume mounting
- Adminer for database management
- Exposed database port

### Production
- Gunicorn with multiple workers
- DEBUG=False
- SMTP email backend
- Named volumes (no direct code mounting)
- Nginx reverse proxy
- SSL/TLS encryption
- Limited exposed ports
- Health checks and auto-restart

## Common Commands

### Development
```bash
# Start
docker-compose -f docker-compose.dev.yml up

# Stop
docker-compose -f docker-compose.dev.yml down

# View logs
docker-compose -f docker-compose.dev.yml logs -f

# Execute commands
docker-compose -f docker-compose.dev.yml exec web python manage.py migrate
```

### Production
```bash
# Start
docker-compose -f docker-compose.prod.yml up -d

# Stop
docker-compose -f docker-compose.prod.yml down

# View logs
docker-compose -f docker-compose.prod.yml logs -f

# Execute commands
docker-compose -f docker-compose.prod.yml exec web python manage.py migrate
```

## Security Considerations

### Development
- ⚠️ Uses hardcoded credentials (acceptable for local dev)
- ⚠️ Exposed database port (convenient for dev tools)
- ⚠️ Debug mode enabled
- ⚠️ Permissive ALLOWED_HOSTS

### Production
- ✅ Environment variables for sensitive data
- ✅ No exposed database port
- ✅ Debug mode disabled
- ✅ Restricted ALLOWED_HOSTS
- ✅ SSL/TLS encryption
- ✅ Security headers configured
- ✅ Health checks and monitoring

## Troubleshooting

### Container won't start
1. Check logs: `docker-compose -f docker-compose.dev.yml logs`
2. Verify ports aren't in use: `lsof -ti:8000,5433,8080`
3. Check health status: `docker-compose -f docker-compose.dev.yml ps`

### Database connection issues
1. Wait for health check to pass
2. Verify environment variables
3. Check network connectivity: `docker network ls`

### Permission issues
1. Check file ownership
2. Verify volume mounts
3. Run with appropriate user permissions

## Further Reading

- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Django Deployment Checklist](https://docs.djangoproject.com/en/4.2/howto/deployment/checklist/)
- [PostgreSQL Docker Image](https://hub.docker.com/_/postgres)
- [Gunicorn Configuration](https://docs.gunicorn.org/en/stable/settings.html)

