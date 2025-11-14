# Deployment Guide

This guide covers deploying the Exhibition Customer Management System to production.

## Pre-Deployment Checklist

### 1. Security Configuration

- [ ] Generate a new `SECRET_KEY` for production
  ```bash
  python -c 'from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())'
  ```
- [ ] Set `DEBUG=False` in production `.env`
- [ ] Configure `ALLOWED_HOSTS` with your domain(s)
- [ ] Use strong database password
- [ ] Set up HTTPS/SSL certificates
- [ ] Configure secure email service
- [ ] Review and update CORS settings if needed

### 2. Environment Variables

Create a production `.env` file with:

```bash
# Django Settings
SECRET_KEY=<your-generated-secret-key>
DEBUG=False
ALLOWED_HOSTS=yourdomain.com,www.yourdomain.com

# Database
DB_NAME=exhibition_db_prod
DB_USER=exhibition_user_prod
DB_PASSWORD=<strong-password>
DB_HOST=db
DB_PORT=5432

# Email (Production)
EMAIL_BACKEND=django.core.mail.backends.smtp.EmailBackend
EMAIL_HOST=smtp.your-provider.com
EMAIL_PORT=587
EMAIL_USE_TLS=True
EMAIL_HOST_USER=neo.sharaf@gmail.com
EMAIL_HOST_PASSWORD=euoxrzuouyirzjng
DEFAULT_FROM_EMAIL=neo.sharaf@gmail.com

# Application
APP_URL=https://yourdomain.com
```

### 3. Database Backup Strategy

Set up automated backups:

```bash
# Create backup script
cat > backup.sh << 'EOF'
#!/bin/bash
BACKUP_DIR="/backups"
DATE=$(date +%Y%m%d_%H%M%S)
docker-compose exec -T db pg_dump -U exhibition_user_prod exhibition_db_prod > $BACKUP_DIR/backup_$DATE.sql
# Keep only last 30 days
find $BACKUP_DIR -name "backup_*.sql" -mtime +30 -delete
EOF

chmod +x backup.sh

# Add to crontab (daily at 2 AM)
0 2 * * * /path/to/exhibition-app/backup.sh
```

## Deployment Options

### Option 1: Docker on VPS (DigitalOcean, Linode, AWS EC2)

#### 1. Server Setup

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Add user to docker group
sudo usermod -aG docker $USER
```

#### 2. Deploy Application

```bash
# Clone/upload your code
git clone <your-repo> /opt/exhibition-app
cd /opt/exhibition-app

# Create production .env file
nano .env
# (Add production settings)

# Build and start
docker-compose -f docker-compose.prod.yml up -d --build

# Run migrations
docker-compose exec web python manage.py migrate

# Create superuser
docker-compose exec web python manage.py createsuperuser

# Collect static files
docker-compose exec web python manage.py collectstatic --noinput
```

#### 3. Set up Nginx Reverse Proxy

```bash
# Install Nginx
sudo apt install nginx

# Create Nginx configuration
sudo nano /etc/nginx/sites-available/exhibition
```

```nginx
server {
    listen 80;
    server_name yourdomain.com www.yourdomain.com;

    location / {
        proxy_pass http://localhost:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /static/ {
        alias /opt/exhibition-app/staticfiles/;
    }

    location /media/ {
        alias /opt/exhibition-app/media/;
    }

    client_max_body_size 10M;
}
```

```bash
# Enable site
sudo ln -s /etc/nginx/sites-available/exhibition /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

#### 4. Set up SSL with Let's Encrypt

```bash
# Install Certbot
sudo apt install certbot python3-certbot-nginx

# Get certificate
sudo certbot --nginx -d yourdomain.com -d www.yourdomain.com

# Auto-renewal is set up automatically
```

### Option 2: Docker on AWS ECS/Fargate

1. Create ECR repository
2. Push Docker image to ECR
3. Create ECS task definition
4. Set up RDS PostgreSQL instance
5. Configure ALB (Application Load Balancer)
6. Deploy ECS service

### Option 3: Kubernetes

1. Create Docker image
2. Push to container registry
3. Create Kubernetes manifests (deployment, service, ingress)
4. Apply manifests to cluster

## Production Docker Compose

Create `docker-compose.prod.yml`:

```yaml
version: '3.8'

services:
  db:
    image: postgres:15-alpine
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./backups:/backups
    environment:
      - POSTGRES_DB=${DB_NAME}
      - POSTGRES_USER=${DB_USER}
      - POSTGRES_PASSWORD=${DB_PASSWORD}
    restart: always
    networks:
      - backend

  web:
    build: .
    command: gunicorn --bind 0.0.0.0:8000 --workers 4 --timeout 120 exhibition_project.wsgi:application
    volumes:
      - static_volume:/app/staticfiles
      - media_volume:/app/media
    expose:
      - 8000
    env_file:
      - .env
    depends_on:
      - db
    restart: always
    networks:
      - backend

  nginx:
    image: nginx:alpine
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - static_volume:/app/staticfiles:ro
      - media_volume:/app/media:ro
    ports:
      - "80:80"
      - "443:443"
    depends_on:
      - web
    restart: always
    networks:
      - backend

volumes:
  postgres_data:
  static_volume:
  media_volume:

networks:
  backend:
    driver: bridge
```

## Monitoring

### Set up Log Monitoring

```bash
# View application logs
docker-compose logs -f web

# View database logs
docker-compose logs -f db

# Set up log rotation
sudo nano /etc/logrotate.d/docker-containers
```

### Health Checks

Add to your monitoring system:
- Database connectivity: `docker-compose exec db pg_isready`
- Web application: `curl http://localhost:8000/admin/`
- Disk space: `df -h`
- Memory usage: `free -m`

## Maintenance

### Regular Updates

```bash
# Pull latest code
git pull origin main

# Rebuild and restart
docker-compose build
docker-compose up -d

# Run migrations
docker-compose exec web python manage.py migrate

# Collect static files
docker-compose exec web python manage.py collectstatic --noinput
```

### Database Maintenance

```bash
# Backup
docker-compose exec db pg_dump -U exhibition_user_prod exhibition_db_prod > backup.sql

# Restore
docker-compose exec -T db psql -U exhibition_user_prod exhibition_db_prod < backup.sql

# Optimize
docker-compose exec db psql -U exhibition_user_prod exhibition_db_prod -c "VACUUM ANALYZE;"
```

## Troubleshooting

### Application won't start
- Check logs: `docker-compose logs web`
- Verify environment variables
- Ensure database is accessible

### Database connection issues
- Check database logs: `docker-compose logs db`
- Verify credentials in `.env`
- Check network connectivity

### Email not sending
- Test SMTP connection
- Check firewall rules
- Verify email credentials
- Check spam folder

## Rollback Procedure

If deployment fails:

```bash
# Stop current version
docker-compose down

# Restore previous version
git checkout <previous-commit>
docker-compose build
docker-compose up -d

# Restore database if needed
docker-compose exec -T db psql -U exhibition_user_prod exhibition_db_prod < backup.sql
```

## Support

For deployment assistance, contact your DevOps team.

