# 🚀 Production Quick Start

## Three Ways to Deploy

### Option 1: Automated Script (Easiest) ⭐

```bash
# On your production server:
cd /opt/exhibition-app

# 1. Create .env file (see below)
nano .env

# 2. Run deployment script
./prod-deploy.sh
```

Done! ✅

---

### Option 2: Using Makefile Commands

```bash
# On your production server:
cd /opt/exhibition-app

# 1. Create .env file
nano .env

# 2. Deploy
make prod-deploy
```

---

### Option 3: Manual Step-by-Step

```bash
# Build
docker-compose -f docker-compose.prod.yml build

# Start database
docker-compose -f docker-compose.prod.yml up -d db

# Wait 10 seconds
sleep 10

# Migrate
docker-compose -f docker-compose.prod.yml exec web python manage.py migrate

# Collect static
docker-compose -f docker-compose.prod.yml exec web python manage.py collectstatic --noinput

# Start all services
docker-compose -f docker-compose.prod.yml up -d

# Create superuser
docker-compose -f docker-compose.prod.yml exec web python manage.py createsuperuser
```

---

## 📝 Production .env Template

Create this file in your production server at `/opt/exhibition-app/.env`:

```env
# Django Settings
SECRET_KEY=GENERATE_A_NEW_SECRET_KEY_HERE
DEBUG=False
ALLOWED_HOSTS=your-domain.com,www.your-domain.com,your-server-ip

# Database (Change passwords!)
DB_NAME=exhibition_db_prod
DB_USER=exhibition_user_prod
DB_PASSWORD=YourStrongPassword123!

# Email Configuration
EMAIL_BACKEND=django.core.mail.backends.smtp.EmailBackend
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USE_TLS=True
EMAIL_HOST_USER=your-email@gmail.com
EMAIL_HOST_PASSWORD=your-app-password
DEFAULT_FROM_EMAIL=your-email@gmail.com

# Application URL
APP_URL=http://your-domain.com
```

**Generate SECRET_KEY:**
```bash
python3 -c 'from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())'
```

---

## 🌐 Access Your App

After deployment:
- **Admin**: `http://your-domain.com/admin`
- **API**: `http://your-domain.com/api/` (if enabled)

---

## 📊 Useful Production Commands

```bash
# View logs
make prod-logs              # All services
make prod-logs-web         # Django logs only
make prod-logs-nginx       # Nginx logs only

# Restart
make prod-restart          # All services

# Stop
make prod-stop

# Database backup
make prod-backup

# Shell access
make prod-shell           # Container shell
make prod-dbshell         # Database shell

# Check status
make prod-ps
```

---

## 🔄 Updating Your App (After Code Changes)

```bash
# Automated
./prod-update.sh

# Or using Make
make prod-update

# Or manually
git pull
docker-compose -f docker-compose.prod.yml build
docker-compose -f docker-compose.prod.yml up -d
make prod-migrate
make prod-collectstatic
```

---

## 🔒 Setup SSL/HTTPS (Recommended)

After basic deployment works:

```bash
# Get SSL certificate
docker run -it --rm \
  -v $(pwd)/certbot/conf:/etc/letsencrypt \
  -v $(pwd)/certbot/www:/var/www/certbot \
  certbot/certbot certonly --webroot \
  --webroot-path=/var/www/certbot \
  --email your-email@example.com \
  --agree-tos \
  -d your-domain.com -d www.your-domain.com

# Update nginx config (see PRODUCTION_SETUP.md)
nano nginx/conf.d/default.conf

# Restart nginx
make prod-restart
```

---

## ✅ Quick Deployment Checklist

Before deploying:
- [ ] Server with Docker installed
- [ ] Domain pointed to server IP (optional)
- [ ] Created `.env` file with production settings
- [ ] Changed SECRET_KEY
- [ ] Set DEBUG=False
- [ ] Updated ALLOWED_HOSTS
- [ ] Changed database passwords
- [ ] Configured email settings

After deploying:
- [ ] Run `./prod-deploy.sh`
- [ ] Create superuser
- [ ] Test admin login
- [ ] Test creating a customer
- [ ] Test email sending
- [ ] Setup SSL (optional)
- [ ] Configure backups

---

## 🆘 Troubleshooting

### Can't connect to admin
```bash
# Check services are running
make prod-ps

# Check web logs
make prod-logs-web

# Check nginx logs
make prod-logs-nginx
```

### Database connection error
```bash
# Check database is healthy
make prod-ps

# Check environment variables
docker-compose -f docker-compose.prod.yml exec web env | grep DB_
```

### 502 Bad Gateway
```bash
# Restart web service
docker-compose -f docker-compose.prod.yml restart web

# Check if port 8000 is accessible
docker-compose -f docker-compose.prod.yml exec nginx wget -O- http://web:8000/admin/
```

---

## 📚 Full Documentation

For detailed instructions, see:
- **PRODUCTION_SETUP.md** - Complete step-by-step guide
- **DEPLOYMENT.md** - Deployment options and strategies
- **DOCKER_ARCHITECTURE.md** - How containers work

---

## 🎯 Production Architecture

```
Internet
   ↓
Nginx (Port 80/443)
   ↓
Django/Gunicorn (Port 8000)
   ↓
PostgreSQL (Port 5432)
```

**Services:**
- `nginx` - Reverse proxy, serves static files, SSL termination
- `web` - Django + Gunicorn (4 workers)
- `db` - PostgreSQL 15
- `certbot` - SSL certificate auto-renewal

---

## 💡 Pro Tips

1. **Always backup before updates:**
   ```bash
   make prod-backup
   ```

2. **Check logs regularly:**
   ```bash
   make prod-logs-web | grep ERROR
   ```

3. **Monitor disk space:**
   ```bash
   df -h
   ```

4. **Keep backups for 30 days:**
   Already configured in backup script!

5. **Use strong passwords:**
   Generate with: `openssl rand -base64 32`

---

## 🚀 You're Ready!

Choose your deployment method above and get started!

For detailed instructions: **See PRODUCTION_SETUP.md** 📖

