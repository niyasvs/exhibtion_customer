# 🚂 Railway Quick Start (5 Minutes)

Deploy to Railway in **5 easy steps**!

---

## Step 1: Create Railway Account (1 min)

1. Go to https://railway.app
2. Click **"Login"** with GitHub
3. Done! ✅

---

## Step 2: Deploy from GitHub (2 min)

1. Click **"New Project"**
2. Select **"Deploy from GitHub repo"**
3. Choose your `exhibition_project` repository
4. Railway starts building automatically

---

## Step 3: Add Database (30 sec)

1. Click **"+ New"** in your project
2. Select **"Database"**
3. Choose **"PostgreSQL"**
4. Done! Railway auto-connects it

---

## Step 4: Set Environment Variables (1 min)

Click on your **web service** → **"Variables"** → Add these:

```bash
# Generate this first: python3 -c 'from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())'
SECRET_KEY=your-generated-key-here

DEBUG=False
ALLOWED_HOSTS=.railway.app,.up.railway.app

# Email (use your Gmail app password)
EMAIL_BACKEND=django.core.mail.backends.smtp.EmailBackend
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USE_TLS=True
EMAIL_HOST_USER=your-email@gmail.com
EMAIL_HOST_PASSWORD=your-gmail-app-password
DEFAULT_FROM_EMAIL=your-email@gmail.com
```

**Click "Deploy"** to restart with new variables.

---

## Step 5: Create Superuser (30 sec)

Install Railway CLI:

```bash
# macOS
brew install railway

# Linux/WSL
bash <(curl -fsSL cli.new)
```

Then:

```bash
railway login
railway link    # Select your project
railway run python manage.py createsuperuser
```

---

## 🎉 You're Live!

Your app is at: `https://your-app.railway.app/admin`

**Login with the superuser you just created!**

---

## 📋 Quick Commands

```bash
# View logs
railway logs

# Run Django commands
railway run python manage.py migrate
railway run python manage.py createsuperuser

# Shell access
railway run python manage.py shell
```

---

## 🔄 Auto-Deploy

Every time you push to GitHub:

```bash
git add .
git commit -m "changes"
git push
```

Railway automatically rebuilds and deploys! 🚀

---

## 💰 Cost

- **Free Tier**: $5 credit/month (enough for small projects)
- **This Project**: ~$3-5/month (fits in free tier!)

---

## 🌐 Custom Domain

1. Go to **Settings** → **Domains**
2. Click **"Custom Domain"**
3. Add your domain
4. Update DNS records
5. SSL auto-configured! ✨

---

## 🆘 Troubleshooting

**Build fails?**
- Check logs in Railway dashboard
- Verify `requirements.txt` is correct

**Can't connect to database?**
- Verify PostgreSQL is added to project
- Check if `DATABASE_URL` variable exists

**Email not working?**
- Use Gmail App Password (not regular password)
- Check EMAIL_* variables are set

**For detailed help:** See `RAILWAY_DEPLOYMENT.md`

---

## ✅ What Railway Does Automatically

- ✅ Builds your app from GitHub
- ✅ Runs migrations on deploy
- ✅ Collects static files
- ✅ Provides PostgreSQL database
- ✅ Sets up HTTPS/SSL
- ✅ Gives you a `.railway.app` domain
- ✅ Auto-deploys on git push
- ✅ Handles scaling
- ✅ Monitors uptime
- ✅ Backs up database

---

## 🎯 Advantages Over Self-Hosting

| Feature | Railway | Self-Hosted VPS |
|---------|---------|-----------------|
| Setup Time | 5 minutes | 30-60 minutes |
| Server Mgmt | None | You manage |
| SSL | Automatic | Manual setup |
| Backups | Automatic | Manual setup |
| Monitoring | Built-in | Setup needed |
| Scaling | 1-click | Reconfigure |
| Cost | $0-5/month | $5-50/month |

---

## 📚 More Info

- **Full Guide**: `RAILWAY_DEPLOYMENT.md`
- **Railway Docs**: https://docs.railway.app
- **Support**: https://discord.gg/railway

---

**That's it! You're deployed on Railway!** 🎊

Enjoy your maintenance-free deployment! 🚂✨

