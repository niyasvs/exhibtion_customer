# Environment Configuration Guide

## Setting Up Your .env File

The application uses environment variables for configuration. You need to create a `.env` file in the project root.

## Development Configuration

For local development, create `.env` with these settings:

```bash
# Django Settings
SECRET_KEY=django-insecure-dev-key-change-in-production-12345678901234567890
DEBUG=True
ALLOWED_HOSTS=localhost,127.0.0.1,0.0.0.0

# Database
DB_NAME=exhibition_db
DB_USER=exhibition_user
DB_PASSWORD=exhibition_pass_2024
DB_HOST=db
DB_PORT=5432

# Email Configuration (Development - Console Backend)
# This will print emails to console instead of sending them
EMAIL_BACKEND=django.core.mail.backends.smtp.EmailBackend
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USE_TLS=True
EMAIL_HOST_USER=your-email@gmail.com
EMAIL_HOST_PASSWORD=your-app-password
DEFAULT_FROM_EMAIL=noreply@exhibition.com

# Application Settings
APP_URL=http://localhost:8000
```

### Quick Setup

Run this command to create the development .env file:

```bash
cat > .env << 'EOF'
SECRET_KEY=django-insecure-dev-key-change-in-production-12345678901234567890
DEBUG=True
ALLOWED_HOSTS=localhost,127.0.0.1,0.0.0.0
DB_NAME=exhibition_db
DB_USER=exhibition_user
DB_PASSWORD=exhibition_pass_2024
DB_HOST=db
DB_PORT=5432
EMAIL_BACKEND=django.core.mail.backends.smtp.EmailBackend
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USE_TLS=True
EMAIL_HOST_USER=your-email@gmail.com
EMAIL_HOST_PASSWORD=your-app-password
DEFAULT_FROM_EMAIL=noreply@exhibition.com
APP_URL=http://localhost:8000
EOF
```

## Production Configuration

For production, create `.env` with these settings:

```bash
# Django Settings
SECRET_KEY=<generate-a-strong-secret-key>
DEBUG=False
ALLOWED_HOSTS=yourdomain.com,www.yourdomain.com

# Database
DB_NAME=exhibition_db_prod
DB_USER=exhibition_user_prod
DB_PASSWORD=<strong-database-password>
DB_HOST=db
DB_PORT=5432

# Email Configuration (Production - SMTP)
EMAIL_BACKEND=django.core.mail.backends.smtp.EmailBackend
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USE_TLS=True
EMAIL_HOST_USER=your-production-email@gmail.com
EMAIL_HOST_PASSWORD=<your-gmail-app-password>
DEFAULT_FROM_EMAIL=your-production-email@gmail.com

# Application Settings
APP_URL=https://yourdomain.com
```

## Generating a Secret Key

To generate a secure secret key for production:

```bash
python -c 'from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())'
```

Or in Docker:

```bash
docker-compose exec web python -c 'from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())'
```

## Email Configuration Options

### Option 1: Console Backend (Development)
Prints emails to console/logs:
```bash
EMAIL_BACKEND=django.core.mail.backends.smtp.EmailBackend
```

### Option 2: Gmail (Production)

1. Enable 2-factor authentication on your Gmail account
2. Generate an App Password:
   - Go to https://myaccount.google.com/apppasswords
   - Select "Mail" and your device
   - Copy the generated password

3. Update .env:
```bash
EMAIL_BACKEND=django.core.mail.backends.smtp.EmailBackend
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USE_TLS=True
EMAIL_HOST_USER=your-email@gmail.com
EMAIL_HOST_PASSWORD=<16-character-app-password>
DEFAULT_FROM_EMAIL=your-email@gmail.com
```

### Option 3: SendGrid

```bash
EMAIL_BACKEND=django.core.mail.backends.smtp.EmailBackend
EMAIL_HOST=smtp.sendgrid.net
EMAIL_PORT=587
EMAIL_USE_TLS=True
EMAIL_HOST_USER=apikey
EMAIL_HOST_PASSWORD=<your-sendgrid-api-key>
DEFAULT_FROM_EMAIL=noreply@yourdomain.com
```

### Option 4: AWS SES

```bash
EMAIL_BACKEND=django.core.mail.backends.smtp.EmailBackend
EMAIL_HOST=email-smtp.us-east-1.amazonaws.com
EMAIL_PORT=587
EMAIL_USE_TLS=True
EMAIL_HOST_USER=<your-smtp-username>
EMAIL_HOST_PASSWORD=<your-smtp-password>
DEFAULT_FROM_EMAIL=noreply@yourdomain.com
```

## Environment Variables Reference

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `SECRET_KEY` | Django secret key for cryptographic signing | None | Yes |
| `DEBUG` | Enable debug mode (never True in production) | False | No |
| `ALLOWED_HOSTS` | Comma-separated list of allowed hostnames | localhost,127.0.0.1 | Yes |
| `DB_NAME` | PostgreSQL database name | exhibition_db | Yes |
| `DB_USER` | PostgreSQL username | exhibition_user | Yes |
| `DB_PASSWORD` | PostgreSQL password | None | Yes |
| `DB_HOST` | PostgreSQL host | db | Yes |
| `DB_PORT` | PostgreSQL port | 5432 | Yes |
| `EMAIL_BACKEND` | Django email backend class | console | Yes |
| `EMAIL_HOST` | SMTP server hostname | smtp.gmail.com | Yes* |
| `EMAIL_PORT` | SMTP server port | 587 | Yes* |
| `EMAIL_USE_TLS` | Use TLS for email | True | Yes* |
| `EMAIL_HOST_USER` | SMTP username | None | Yes* |
| `EMAIL_HOST_PASSWORD` | SMTP password | None | Yes* |
| `DEFAULT_FROM_EMAIL` | Default sender email | noreply@exhibition.com | Yes |
| `APP_URL` | Application base URL | http://localhost:8000 | Yes |

*Required only when using SMTP email backend

## Verifying Configuration

After creating your `.env` file, verify it's loaded correctly:

```bash
# Start the application
docker-compose up -d

# Check if environment variables are loaded
docker-compose exec web python manage.py shell

# In the Django shell:
from django.conf import settings
print(settings.DEBUG)
print(settings.DATABASES['default']['NAME'])
print(settings.EMAIL_BACKEND)
exit()
```

## Troubleshooting

### .env file not loading

1. Ensure the file is named exactly `.env` (not `.env.txt`)
2. Ensure the file is in the project root directory
3. Check file permissions: `chmod 600 .env`
4. Restart Docker containers: `docker-compose down && docker-compose up -d`

### Email not sending

1. Check `EMAIL_BACKEND` is set to SMTP backend
2. Verify email credentials are correct
3. Check if your email provider allows SMTP access
4. For Gmail, ensure you're using an App Password, not your regular password
5. Check firewall/network settings

### Database connection errors

1. Verify database credentials in `.env`
2. Ensure `DB_HOST=db` (the Docker service name)
3. Wait for database to be fully ready (check `docker-compose logs db`)
4. Check if PostgreSQL container is running: `docker-compose ps`

## Security Best Practices

1. **Never commit `.env` to version control** - It's already in `.gitignore`
2. **Use strong passwords** - Especially for production databases
3. **Rotate secrets regularly** - Change SECRET_KEY and passwords periodically
4. **Limit access** - Only give `.env` access to necessary personnel
5. **Use different credentials** - Different secrets for dev/staging/production
6. **Enable DEBUG=False in production** - Always disable debug mode
7. **Use environment-specific .env files** - `.env.dev`, `.env.staging`, `.env.prod`

## Example: Different Environments

### .env.dev
```bash
DEBUG=True
EMAIL_BACKEND=django.core.mail.backends.smtp.EmailBackend
```

### .env.staging
```bash
DEBUG=False
EMAIL_BACKEND=django.core.mail.backends.smtp.EmailBackend
# ... staging email config
```

### .env.prod
```bash
DEBUG=False
EMAIL_BACKEND=django.core.mail.backends.smtp.EmailBackend
# ... production email config
```

Then use:
```bash
docker-compose --env-file .env.prod up -d
```

