# Quick Start Guide

Get the Exhibition Customer Management System up and running in 5 minutes!

## Prerequisites

- Docker installed
- Docker Compose installed

## Steps

### 1. Navigate to project directory

```bash
cd /Users/nsharaf/researches/exhibition-app
```

### 2. Create environment file

The `.env` file should already exist with development defaults. If not:

```bash
cp .env.example .env
```

For development, the default settings will work fine (emails will be printed to console).

### 3. Run the setup script

```bash
chmod +x setup.sh
./setup.sh
```

This will:
- Build Docker images
- Start PostgreSQL and Django services
- Run database migrations
- Prompt you to create a superuser
- Collect static files

**OR** do it manually:

```bash
# Build and start
docker-compose up -d --build

# Wait 10 seconds for database to be ready
sleep 10

# Run migrations
docker-compose exec web python manage.py migrate

# Create superuser
docker-compose exec web python manage.py createsuperuser

# Collect static files
docker-compose exec web python manage.py collectstatic --noinput
```

### 4. Access the application

Open your browser and go to:
```
http://localhost:8000/admin
```

Log in with the superuser credentials you just created.

## First Steps

### Add Your First Customer

1. Click **"Customers"** → **"+ Add Customer"**
2. Fill in:
   - Name: John Doe
   - Email: john@example.com
   - Phone: +1234567890
3. Click **"Save"**
4. Check the console output (in Docker logs) to see the email that would be sent:
   ```bash
   docker-compose logs web
   ```

### Add Your First Bill

1. Click **"Bills"** → **"+ Add Bill"**
2. Select the customer you just created
3. View the customer information displayed
4. Enter amount: 150.00
5. Add description: "Exhibition booth rental"
6. Click **"Save"**

### View Customer Summary

1. Click **"Customers"** in the left menu
2. You'll see:
   - Customer ID
   - Contact information
   - Number of bills
   - Total billing amount
   - Email status

## Testing Email (Production)

To actually send emails instead of printing to console:

1. Edit `.env`:
   ```
   EMAIL_BACKEND=django.core.mail.backends.smtp.EmailBackend
   EMAIL_HOST=smtp.gmail.com
   EMAIL_PORT=587
   EMAIL_USE_TLS=True
   EMAIL_HOST_USER=your-email@gmail.com
   EMAIL_HOST_PASSWORD=your-app-password
   DEFAULT_FROM_EMAIL=your-email@gmail.com
   ```

2. For Gmail:
   - Enable 2-factor authentication
   - Generate App Password at: https://myaccount.google.com/apppasswords
   - Use that password in `EMAIL_HOST_PASSWORD`

3. Restart the application:
   ```bash
   docker-compose restart web
   ```

## Common Commands

```bash
# View logs
docker-compose logs -f web

# Stop everything
docker-compose down

# Start again
docker-compose up -d

# Access Django shell
docker-compose exec web python manage.py shell

# Access database
docker-compose exec db psql -U exhibition_user -d exhibition_db
```

## Troubleshooting

### Can't access http://localhost:8000
- Check if services are running: `docker-compose ps`
- Check logs: `docker-compose logs web`
- Try restarting: `docker-compose restart`

### Database connection errors
- Ensure database is healthy: `docker-compose ps db`
- Wait longer for database to start
- Check database logs: `docker-compose logs db`

### Forgot superuser password
```bash
docker-compose exec web python manage.py changepassword <username>
```

## What's Next?

- Read the full [README.md](README.md) for detailed documentation
- Check [DEPLOYMENT.md](DEPLOYMENT.md) for production deployment
- Start adding customers and managing bills!

## Need Help?

Check the logs:
```bash
docker-compose logs -f
```

Restart everything:
```bash
docker-compose down
docker-compose up -d --build
docker-compose exec web python manage.py migrate
```

