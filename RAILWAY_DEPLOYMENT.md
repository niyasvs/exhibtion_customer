# 🚂 Railway Deployment Guide

Deploy your Exhibition Customer Management System to Railway in **under 10 minutes**!

## 🎯 Why Railway?

- ✅ **Zero Server Management** - No need to manage servers or Docker
- ✅ **Free Tier Available** - $5 credit per month (hobby plan)
- ✅ **Automatic SSL** - HTTPS enabled automatically
- ✅ **Easy Database Setup** - PostgreSQL with one click
- ✅ **Git Integration** - Auto-deploy on push
- ✅ **Environment Variables** - Easy configuration
- ✅ **Custom Domains** - Free `.railway.app` domain + custom domain support

---

## 📋 Prerequisites

- GitHub account (or GitLab/Bitbucket)
- Railway account (sign up at https://railway.app)
- Your code pushed to a Git repository

---

## 🚀 Quick Deployment (3 Steps)

### Step 1: Create Railway Account

1. Go to https://railway.app
2. Click **"Login"** or **"Start a New Project"**
3. Sign in with GitHub (recommended)

---

### Step 2: Create New Project

1. Click **"New Project"**
2. Select **"Deploy from GitHub repo"**
3. Select your `exhibition_project` repository
4. Railway will automatically detect it's a Django project

---

### Step 3: Add PostgreSQL Database

1. In your project dashboard, click **"+ New"**
2. Select **"Database"**
3. Choose **"PostgreSQL"**
4. Railway will create and link the database automatically

**That's it!** Railway will automatically:
- Build your application
- Run migrations
- Collect static files
- Deploy to a URL like: `https://your-app.railway.app`

---

## ⚙️ Configure Environment Variables

After creating your project:

1. Click on your **web service**
2. Go to **"Variables"** tab
3. Add these environment variables:

### Required Variables

```
SECRET_KEY=your-generated-secret-key-here
DEBUG=False
ALLOWED_HOSTS=.railway.app,.up.railway.app,your-custom-domain.com

# Email Configuration (Gmail example)
EMAIL_BACKEND=django.core.mail.backends.smtp.EmailBackend
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USE_TLS=True
EMAIL_HOST_USER=your-email@gmail.com
EMAIL_HOST_PASSWORD=your-app-password
DEFAULT_FROM_EMAIL=your-email@gmail.com
```

### Database Variables (Auto-configured)

Railway automatically provides these when you add PostgreSQL:
- `DATABASE_URL` - Full database connection string
- `PGHOST`, `PGPORT`, `PGUSER`, `PGPASSWORD`, `PGDATABASE`

**Note**: You don't need to set `DB_NAME`, `DB_USER`, etc. manually - Railway handles this!

---

## 🔧 Update Django Settings for Railway

Railway provides database credentials via `DATABASE_URL`. Update your `settings.py`:

```python
# At the top of settings.py, add:
import dj_database_url

# Replace DATABASES configuration with:
if 'DATABASE_URL' in os.environ:
    # Railway deployment
    DATABASES = {
        'default': dj_database_url.config(
            conn_max_age=600,
            conn_health_checks=True,
        )
    }
else:
    # Local development
    DATABASES = {
        'default': {
            'ENGINE': 'django.db.backends.postgresql',
            'NAME': env('DB_NAME', default='exhibition_db'),
            'USER': env('DB_USER', default='exhibition_user'),
            'PASSWORD': env('DB_PASSWORD', default='exhibition_pass_2024'),
            'HOST': env('DB_HOST', default='db'),
            'PORT': env('DB_PORT', default='5432'),
        }
    }
```

Add to `requirements.txt`:
```
dj-database-url==2.1.0
```

---

## 📝 Generate SECRET_KEY

Run this locally to generate a secure key:

```bash
python3 -c 'from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())'
```

Copy the output and add it to Railway's environment variables.

---

## 🌐 Access Your Application

After deployment completes:

1. Click on your web service in Railway
2. Go to **"Settings"** tab
3. Find **"Domains"** section
4. Railway will provide a URL like: `https://exhibition-project-production-xxxx.up.railway.app`

**Access admin:**
```
https://your-app.railway.app/admin
```

---

## 👤 Create Superuser

You need to create an admin user via Railway CLI or using the web terminal:

### Method 1: Railway CLI (Recommended)

Install Railway CLI:
```bash
# macOS
brew install railway

# Linux/WSL
bash <(curl -fsSL cli.new)

# Windows
scoop install railway
```

Login and run command:
```bash
railway login
railway link  # Select your project
railway run python manage.py createsuperuser
```

### Method 2: Railway Web Terminal

1. Go to your web service in Railway
2. Click **"..."** menu → **"View Logs"**
3. Switch to **"Terminal"** tab
4. Run:
```bash
python manage.py createsuperuser
```

---

## 🔄 Automatic Deployments

Railway automatically deploys when you push to your repository:

```bash
# Make changes locally
git add .
git commit -m "Updated something"
git push origin main

# Railway will automatically:
# 1. Detect the push
# 2. Build your application
# 3. Run migrations
# 4. Deploy new version
```

---

## 📊 Monitoring & Logs

### View Logs
1. Go to your service in Railway
2. Click **"View Logs"**
3. See real-time logs from your application

### Monitor Resources
1. Go to your service
2. Click **"Metrics"** tab
3. View CPU, Memory, Network usage

### View Database
1. Click on PostgreSQL service
2. Click **"Data"** tab
3. Browse tables and run queries

---

## 💰 Pricing

### Hobby Plan (Free)
- $5 credit per month (free)
- Enough for small projects
- Sleep after inactivity (can be disabled)
- 512MB RAM, 1GB storage

### Pro Plan ($20/month)
- $20 worth of usage included
- No sleep
- More resources
- Priority support

**Estimated cost for this project:**
- Small usage: ~$3-5/month (fits in free tier!)
- Medium usage: ~$8-12/month

---

## 🎨 Custom Domain Setup

1. Go to your web service
2. Click **"Settings"** → **"Domains"**
3. Click **"Custom Domain"**
4. Enter your domain (e.g., `exhibition.yourdomain.com`)
5. Add the DNS records Railway provides to your domain registrar

Railway automatically provisions SSL certificate! 🔒

---

## 📦 Static Files Configuration

Railway serves static files through WhiteNoise (already configured in your project).

To verify static files work:
```python
# In settings.py, ensure you have:
MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'whitenoise.middleware.WhiteNoiseMiddleware',  # Must be after SecurityMiddleware
    # ... other middleware
]

STATIC_ROOT = BASE_DIR / 'staticfiles'
STATICFILES_STORAGE = 'whitenoise.storage.CompressedManifestStaticFilesStorage'
```

---

## 🔐 Environment Variables Reference

Complete list of variables to set in Railway:

```bash
# Django Core
SECRET_KEY=<generate-new-key>
DEBUG=False
ALLOWED_HOSTS=.railway.app,.up.railway.app

# Email (Gmail)
EMAIL_BACKEND=django.core.mail.backends.smtp.EmailBackend
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USE_TLS=True
EMAIL_HOST_USER=your-email@gmail.com
EMAIL_HOST_PASSWORD=your-gmail-app-password
DEFAULT_FROM_EMAIL=your-email@gmail.com

# Application (Optional)
APP_URL=https://your-app.railway.app
```

**Note**: `DATABASE_URL` is automatically set by Railway when you add PostgreSQL.

---

## 🔧 Troubleshooting

### Build Fails

**Check buildpacks:**
1. Go to **Settings** → **Build**
2. Ensure builder is set to **Dockerfile** or **Nixpacks**

**Check logs:**
```
View Logs → Build Logs
```

### Database Connection Error

**Verify PostgreSQL is added:**
1. Check PostgreSQL service exists in project
2. Verify `DATABASE_URL` exists in Variables tab
3. Restart the web service

### Static Files Not Loading

**Run collectstatic:**
```bash
railway run python manage.py collectstatic --noinput
```

**Verify WhiteNoise is installed:**
```bash
# Check requirements.txt includes:
whitenoise==6.6.0
```

### Email Not Sending

**Check Gmail App Password:**
1. Use App Password, not regular password
2. Verify EMAIL_* variables are set correctly
3. Check logs for SMTP errors

### Application Won't Start

**Check start command:**
1. Go to **Settings** → **Deploy**
2. Verify start command includes migrations:
```bash
python manage.py migrate && gunicorn --bind 0.0.0.0:$PORT exhibition_project.wsgi:application
```

---

## 🎯 Railway-Specific Files

I've created these files for Railway deployment:

1. **`railway.json`** - Railway configuration
2. **`Procfile`** - Start command (alternative to railway.json)
3. **`nixpacks.toml`** - Nixpacks build configuration

Railway will automatically detect and use these files.

---

## 🚀 Deployment Checklist

- [ ] Created Railway account
- [ ] Created new project from GitHub
- [ ] Added PostgreSQL database
- [ ] Set all environment variables
- [ ] Generated and set SECRET_KEY
- [ ] Set DEBUG=False
- [ ] Updated ALLOWED_HOSTS
- [ ] Configured email settings
- [ ] Deployment completed successfully
- [ ] Created superuser
- [ ] Tested admin login
- [ ] Tested creating customer
- [ ] Tested sending email
- [ ] Tested Excel export

---

## 📱 Mobile/Tablet Access

Railway URLs work perfectly on mobile devices:
- Automatic HTTPS
- Responsive admin interface
- Works on all devices

---

## 🔄 Update Your Application

### Push Changes
```bash
git add .
git commit -m "Your changes"
git push origin main
```

Railway automatically:
1. Detects the push
2. Rebuilds the application
3. Runs migrations
4. Deploys new version
5. Zero downtime!

### Manual Deploy
In Railway dashboard:
1. Click **"..."** menu
2. Select **"Redeploy"**

### Rollback
1. Go to **"Deployments"** tab
2. Find previous deployment
3. Click **"..."** → **"Rollback"**

---

## 💾 Database Backups

### Automatic Backups
Railway automatically backs up PostgreSQL daily (Pro plan).

### Manual Backup
```bash
# Using Railway CLI
railway run pg_dump $DATABASE_URL > backup.sql
```

### Restore Backup
```bash
railway run psql $DATABASE_URL < backup.sql
```

---

## 📊 Scaling

### Vertical Scaling (More Resources)
1. Go to service **Settings**
2. Adjust **Resources**:
   - RAM: 512MB → 8GB
   - CPU: Shared → Dedicated

### Horizontal Scaling (More Instances)
Upgrade to Team plan for multiple replicas.

---

## 🎉 Advantages of Railway vs Self-Hosted

| Feature | Railway | Self-Hosted |
|---------|---------|-------------|
| Setup Time | 10 minutes | 30-60 minutes |
| Server Management | None | Full responsibility |
| SSL/HTTPS | Automatic | Manual setup |
| Scaling | Click a button | Configure manually |
| Monitoring | Built-in | Setup required |
| Backups | Automatic | Setup required |
| Cost | $0-20/month | $5-50/month + time |
| Maintenance | Zero | Regular updates |

---

## 🆘 Getting Help

### Railway Support
- Discord: https://discord.gg/railway
- Docs: https://docs.railway.app
- Status: https://status.railway.app

### Check Service Status
1. Railway dashboard → Service
2. View **"Deployments"** for history
3. Check **"Logs"** for errors
4. View **"Metrics"** for resource usage

---

## 🎓 Best Practices

1. **Use environment variables** for all secrets
2. **Never commit `.env`** to Git
3. **Monitor usage** to avoid surprises
4. **Set up alerts** for errors (Pro plan)
5. **Test in staging** before deploying to production
6. **Keep dependencies updated** regularly

---

## 📚 Next Steps

1. **Custom Domain**: Add your own domain
2. **Email Service**: Consider SendGrid/Mailgun for better deliverability
3. **Monitoring**: Set up error tracking (Sentry)
4. **CDN**: Use CloudFlare for better performance
5. **Backups**: Set up automated backup downloads

---

## 🎊 You're Live on Railway!

Your application is now deployed and accessible worldwide at:
```
https://your-app.railway.app/admin
```

Enjoy Railway's simplicity! 🚂✨

---

## 📞 Quick Commands Reference

```bash
# Railway CLI
railway login                              # Login to Railway
railway link                               # Link to project
railway run python manage.py migrate      # Run migrations
railway run python manage.py createsuperuser  # Create admin
railway logs                               # View logs
railway status                             # Check deployment status
```

---

**Deployment complete!** 🎉

For issues, check Railway docs or this project's troubleshooting section.

