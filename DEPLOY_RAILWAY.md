# 🚂 Deploy to Railway - Quick Steps

## 3-Step Deployment

### 1️⃣ Railway Setup (2 min)

```bash
# Go to railway.app
# Login with GitHub
# Click "New Project"  
# Select "Deploy from GitHub repo"
# Choose your repository
# Add PostgreSQL database (click "+ New" → "Database" → "PostgreSQL")
```

### 2️⃣ Set Variables (1 min)

Click on web service → "Variables" → Add:

```env
SECRET_KEY=<run command below to generate>
DEBUG=False
ALLOWED_HOSTS=.railway.app
EMAIL_BACKEND=django.core.mail.backends.smtp.EmailBackend
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USE_TLS=True
EMAIL_HOST_USER=your@gmail.com
EMAIL_HOST_PASSWORD=your-app-password
DEFAULT_FROM_EMAIL=your@gmail.com
```

**Generate SECRET_KEY:**
```bash
python3 -c 'from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())'
```

### 3️⃣ Create Admin (1 min)

```bash
# Install Railway CLI
brew install railway  # macOS
# OR
bash <(curl -fsSL cli.new)  # Linux

# Create superuser
railway login
railway link
railway run python manage.py createsuperuser
```

## ✅ Done!

Visit: `https://your-app.railway.app/admin`

---

## 📚 More Info

- **Quick Guide**: `RAILWAY_QUICKSTART.md` (5 min read)
- **Full Guide**: `RAILWAY_DEPLOYMENT.md` (detailed)
- **Summary**: `RAILWAY_SUMMARY.md` (overview)
- **Comparison**: `DEPLOYMENT_COMPARISON.md` (Railway vs VPS)

---

## 💰 Cost

- **Free tier**: $5 credit/month
- **This project**: ~$3-5/month (fits in free tier!)

---

## 🔄 Update Your App

```bash
git add .
git commit -m "changes"
git push

# Railway automatically deploys! 🎉
```

---

**That's it! You're deployed! 🚀**

