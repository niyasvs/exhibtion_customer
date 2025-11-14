# Production Deployment Guide

## 🎯 Quick Production Deployment

This guide will help you deploy the Exhibition Customer Management System to production in **under 30 minutes**.

---

## 📋 Prerequisites

- A server (VPS) with:
  - Ubuntu 20.04+ or similar Linux distribution
  - Minimum 2GB RAM, 2 CPU cores
  - 20GB+ disk space
  - Public IP address
- A domain name (optional but recommended)
- SSH access to your server

---

## 🚀 Step-by-Step Deployment

### Step 1: Server Setup (One-Time)

SSH into your server and run:

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.23.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Add your user to docker group
sudo usermod -aG docker $USER

# Log out and back in for group changes to take effect
exit
# SSH back in
```

Verify installation:
```bash
docker --version
docker-compose --version
```

---

### Step 2: Upload Your Code

**Option A: Using Git (Recommended)**
```bash
# Install git if needed
sudo apt install git -y

# Clone your repository
cd /opt
sudo mkdir exhibition-app
sudo chown $USER:$USER exhibition-app
cd exhibition-app
git clone <your-repo-url> .
```

**Option B: Using SCP/SFTP**
```bash
# From your local machine
scp -r /path/to/exhibition_project user@your-server-ip:/opt/exhibition-app
```

---

### Step 3: Create Production Environment File

On your server:

```bash
cd /opt/exhibition-app

# Create production .env file
cat > .env << 'EOF'
# Django Settings
SECRET_KEY=your-production-secret-key-change-this-immediately
DEBUG=False
ALLOWED_HOSTS=your-domain.com,www.your-domain.com,your-server-ip

# Database (Use strong passwords!)
DB_NAME=exhibition_db_prod
DB_USER=exhibition_user_prod
DB_PASSWORD=StrongPassword123!ChangeThis

# Email Configuration (Gmail example)
EMAIL_BACKEND=django.core.mail.backends.smtp.EmailBackend
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USE_TLS=True
EMAIL_HOST_USER=your-email@gmail.com
EMAIL_HOST_PASSWORD=your-app-password
DEFAULT_FROM_EMAIL=your-email@gmail.com

# Application URL
APP_URL=http://your-domain.com
EOF
```

**Generate a secure SECRET_KEY:**
```bash
python3 -c 'from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())'
```
Copy the output and replace `your-production-secret-key-change-this-immediately` in `.env`

---

### Step 4: Create Required Directories

```bash
cd /opt/exhibition-app

# Create directories for nginx and SSL certificates
mkdir -p nginx/conf.d
mkdir -p certbot/conf
mkdir -p certbot/www
mkdir -p backups
```

---

### Step 5: Configure Nginx

Create nginx configuration:

```bash
cat > nginx/conf.d/default.conf << 'EOF'
upstream web {
    server web:8000;
}

server {
    listen 80;
    server_name your-domain.com www.your-domain.com;
    
    # Let's Encrypt verification
    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }
    
    # Redirect to HTTPS (comment out initially until SSL is setup)
    # location / {
    #     return 301 https://$host$request_uri;
    # }
    
    # Temporary HTTP access (remove after SSL setup)
    location / {
        proxy_pass http://web;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    location /static/ {
        alias /app/staticfiles/;
    }
    
    location /media/ {
        alias /app/media/;
    }
}

# HTTPS configuration (uncomment after SSL setup)
# server {
#     listen 443 ssl;
#     server_name your-domain.com www.your-domain.com;
#     
#     ssl_certificate /etc/letsencrypt/live/your-domain.com/fullchain.pem;
#     ssl_certificate_key /etc/letsencrypt/live/your-domain.com/privkey.pem;
#     
#     location / {
#         proxy_pass http://web;
#         proxy_set_header Host $host;
#         proxy_set_header X-Real-IP $remote_addr;
#         proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
#         proxy_set_header X-Forwarded-Proto $scheme;
#     }
#     
#     location /static/ {
#         alias /app/staticfiles/;
#     }
#     
#     location /media/ {
#         alias /app/media/;
#     }
# }
EOF
```

**Replace `your-domain.com` with your actual domain** (or use your server IP for testing)

---

### Step 6: Build and Start Services

```bash
cd /opt/exhibition-app

# Build the Docker images
docker-compose -f docker-compose.prod.yml build

# Start services (without nginx initially)
docker-compose -f docker-compose.prod.yml up -d db web

# Wait for database to be ready (about 10 seconds)
sleep 10

# Run database migrations
docker-compose -f docker-compose.prod.yml exec web python manage.py migrate

# Collect static files
docker-compose -f docker-compose.prod.yml exec web python manage.py collectstatic --noinput

# Create superuser
docker-compose -f docker-compose.prod.yml exec web python manage.py createsuperuser
```

---

### Step 7: Start Nginx

```bash
# Start nginx
docker-compose -f docker-compose.prod.yml up -d nginx

# Check all services are running
docker-compose -f docker-compose.prod.yml ps
```

You should see all services "Up" and healthy.

---

### Step 8: Test Your Deployment

**Test the application:**
```bash
# Visit in browser
http://your-domain.com/admin
# or
http://your-server-ip/admin
```

**Check logs if something goes wrong:**
```bash
docker-compose -f docker-compose.prod.yml logs -f web
```

---

## 🔒 Step 9: Setup SSL/HTTPS (Optional but Recommended)

If you have a domain name:

### 9.1: Get SSL Certificate

```bash
cd /opt/exhibition-app

# Stop certbot if running
docker-compose -f docker-compose.prod.yml stop certbot

# Get certificate (replace with your email and domain)
docker run -it --rm \
  -v $(pwd)/certbot/conf:/etc/letsencrypt \
  -v $(pwd)/certbot/www:/var/www/certbot \
  certbot/certbot certonly --webroot \
  --webroot-path=/var/www/certbot \
  --email your-email@example.com \
  --agree-tos \
  --no-eff-email \
  -d your-domain.com -d www.your-domain.com
```

### 9.2: Update Nginx Config for HTTPS

Edit `nginx/conf.d/default.conf`:
- Uncomment the HTTPS server block
- Uncomment the redirect in the HTTP server block
- Update domain names

```bash
nano nginx/conf.d/default.conf
# OR
vi nginx/conf.d/default.conf
```

### 9.3: Restart Nginx

```bash
docker-compose -f docker-compose.prod.yml restart nginx

# Start certbot for auto-renewal
docker-compose -f docker-compose.prod.yml up -d certbot
```

Now visit: `https://your-domain.com/admin` 🎉

---

## 📊 Useful Production Commands

### View Logs
```bash
# All services
docker-compose -f docker-compose.prod.yml logs -f

# Specific service
docker-compose -f docker-compose.prod.yml logs -f web
docker-compose -f docker-compose.prod.yml logs -f nginx
```

### Restart Services
```bash
docker-compose -f docker-compose.prod.yml restart
docker-compose -f docker-compose.prod.yml restart web
```

### Stop Services
```bash
docker-compose -f docker-compose.prod.yml down
```

### Update Code
```bash
cd /opt/exhibition-app
git pull  # if using git
docker-compose -f docker-compose.prod.yml build
docker-compose -f docker-compose.prod.yml up -d
docker-compose -f docker-compose.prod.yml exec web python manage.py migrate
docker-compose -f docker-compose.prod.yml exec web python manage.py collectstatic --noinput
```

### Database Backup
```bash
# Manual backup
docker-compose -f docker-compose.prod.yml exec -T db \
  pg_dump -U exhibition_user_prod exhibition_db_prod > backups/backup_$(date +%Y%m%d_%H%M%S).sql

# Restore from backup
docker-compose -f docker-compose.prod.yml exec -T db \
  psql -U exhibition_user_prod exhibition_db_prod < backups/backup_file.sql
```

### Monitor Resources
```bash
docker stats
```

---

## 🔧 Automated Backup Setup

Create a backup script:

```bash
cat > /opt/exhibition-app/backup.sh << 'EOF'
#!/bin/bash
cd /opt/exhibition-app
BACKUP_FILE="backups/backup_$(date +%Y%m%d_%H%M%S).sql"
docker-compose -f docker-compose.prod.yml exec -T db \
  pg_dump -U exhibition_user_prod exhibition_db_prod > "$BACKUP_FILE"
echo "Backup created: $BACKUP_FILE"

# Keep only last 30 days of backups
find backups/ -name "backup_*.sql" -mtime +30 -delete
EOF

chmod +x /opt/exhibition-app/backup.sh
```

Add to crontab (daily at 2 AM):
```bash
crontab -e

# Add this line:
0 2 * * * /opt/exhibition-app/backup.sh >> /opt/exhibition-app/backups/backup.log 2>&1
```

---

## 🔥 Firewall Configuration

```bash
# Allow SSH (if not already allowed)
sudo ufw allow 22/tcp

# Allow HTTP and HTTPS
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Enable firewall
sudo ufw enable
```

---

## 🚨 Troubleshooting

### Services won't start
```bash
# Check logs
docker-compose -f docker-compose.prod.yml logs

# Check if ports are in use
sudo netstat -tlnp | grep -E '(80|443|5432)'

# Restart Docker
sudo systemctl restart docker
```

### Can't connect to database
```bash
# Check database is running
docker-compose -f docker-compose.prod.yml ps db

# Check environment variables
docker-compose -f docker-compose.prod.yml exec web env | grep DB_
```

### Nginx 502 Bad Gateway
```bash
# Check web service is running
docker-compose -f docker-compose.prod.yml ps web

# Check web logs
docker-compose -f docker-compose.prod.yml logs web

# Restart web service
docker-compose -f docker-compose.prod.yml restart web
```

### SSL Certificate Issues
```bash
# Check certificate files exist
ls -la certbot/conf/live/your-domain.com/

# Test nginx config
docker-compose -f docker-compose.prod.yml exec nginx nginx -t

# Renew certificate manually
docker run -it --rm \
  -v $(pwd)/certbot/conf:/etc/letsencrypt \
  -v $(pwd)/certbot/www:/var/www/certbot \
  certbot/certbot renew
```

---

## 📋 Production Checklist

Before going live:

- [ ] Changed SECRET_KEY to a strong, unique value
- [ ] Set DEBUG=False
- [ ] Updated ALLOWED_HOSTS with your domain
- [ ] Changed default database passwords
- [ ] Configured real email service (not console backend)
- [ ] Set up SSL/HTTPS
- [ ] Tested admin login
- [ ] Tested customer creation and email sending
- [ ] Tested bill creation
- [ ] Tested Excel export
- [ ] Set up automated backups
- [ ] Configured firewall
- [ ] Documented admin credentials securely
- [ ] Set up monitoring (optional)

---

## 🎉 You're Live!

Your application is now running in production at:
- **HTTP**: `http://your-domain.com`
- **HTTPS**: `https://your-domain.com` (if SSL configured)
- **Admin**: `https://your-domain.com/admin`

---

## 📞 Support

If you encounter issues:
1. Check logs: `docker-compose -f docker-compose.prod.yml logs -f`
2. Review troubleshooting section above
3. Check DEPLOYMENT.md for additional details
4. Verify all environment variables are correct

---

## 🔄 Maintenance

### Weekly
- Check disk space: `df -h`
- Review logs for errors
- Test backup restoration

### Monthly
- Update system: `sudo apt update && sudo apt upgrade`
- Review security updates
- Check SSL certificate expiry

### As Needed
- Update application code
- Scale workers if needed (edit docker-compose.prod.yml)
- Optimize database if performance degrades

---

**Your Exhibition Customer Management System is production-ready! 🚀**

