#!/bin/bash

# Script to create .env file for Exhibition App

echo "=========================================="
echo "Creating .env file"
echo "=========================================="
echo ""

ENV_FILE=".env"

if [ -f "$ENV_FILE" ]; then
    echo "⚠️  Warning: .env file already exists!"
    read -p "Do you want to overwrite it? (y/n) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Keeping existing .env file. Exiting."
        exit 0
    fi
fi

cat > $ENV_FILE << 'EOF'
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
EMAIL_BACKEND=django.core.mail.backends.smtp.EmailBackend
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USE_TLS=True
EMAIL_HOST_USER=neo.sharaf@gmail.com
EMAIL_HOST_PASSWORD=euoxrzuouyirzjng
DEFAULT_FROM_EMAIL=neo.sharaf@gmail.com

# Application Settings
APP_URL=http://localhost:8000
EOF

echo "✅ .env file created successfully!"
echo ""
echo "📝 Note: This is a DEVELOPMENT configuration."
echo ""
echo "Current settings:"
echo "  - DEBUG=True (development mode)"
echo "  - Emails will print to console (not sent)"
echo "  - Default database credentials"
echo ""
echo "To enable email sending:"
echo "  1. Set EMAIL_BACKEND=django.core.mail.backends.smtp.EmailBackend"
echo "  2. Update EMAIL_HOST_USER with your email"
echo "  3. Update EMAIL_HOST_PASSWORD with your email password"
echo "  4. For Gmail, use an App Password from https://myaccount.google.com/apppasswords"
echo ""
echo "For production deployment:"
echo "  - Generate a new SECRET_KEY"
echo "  - Set DEBUG=False"
echo "  - Update ALLOWED_HOSTS with your domain"
echo "  - Use strong database password"
echo "  - Configure production email settings"
echo ""
echo "See ENV_SETUP.md for detailed configuration options."
echo ""

