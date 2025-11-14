# Exhibition Customer Management System

A production-ready Django application for managing customers and billing at exhibitions. The system provides admin-only access for customer registration, automatic QR code generation, email notifications, and billing management.

## Features

### Flow 1: Customer Registration
- Admin enters customer details (name, email, phone)
- System automatically generates a unique 8-character alphanumeric customer ID
- Generates a QR code on-the-fly for the customer ID
- Sends an email to the customer with:
  - Their unique customer ID
  - Attached QR code image
- Customer data is saved to PostgreSQL database (QR codes are generated dynamically, not stored)

### Flow 2: Billing Management
- Admin searches/enters customer ID
- System fetches and displays customer information
- Admin can add bill amounts with optional descriptions
- Multiple bills can be saved for the same customer
- View total billing amount per customer

## Technology Stack

- **Backend**: Django 4.2.7
- **Database**: PostgreSQL 15
- **Containerization**: Docker & Docker Compose
- **Web Server**: Gunicorn
- **Python**: 3.11
- **Libraries**: 
  - qrcode & Pillow (QR code generation)
  - psycopg2 (PostgreSQL adapter)
  - django-environ (environment management)

## Project Structure

```
exhibition-app/
├── exhibition_project/       # Django project settings
│   ├── settings.py          # Main configuration
│   ├── urls.py              # URL routing
│   ├── wsgi.py              # WSGI application
│   └── asgi.py              # ASGI application
├── customers/                # Customer management app
│   ├── models.py            # Customer & Bill models
│   ├── admin.py             # Admin interface
│   ├── utils.py             # QR code & email utilities
│   └── migrations/          # Database migrations
├── media/                    # Media files directory
├── staticfiles/             # Static files
├── docker-compose.yml       # Docker Compose configuration
├── Dockerfile               # Docker image definition
├── requirements.txt         # Python dependencies
├── manage.py               # Django management script
└── README.md               # This file
```

## Prerequisites

- Docker (20.10 or later)
- Docker Compose (2.0 or later)
- (Optional) Python 3.11+ for local development
- (Optional) Railway account for easy cloud deployment

## Deployment Options

### Option 1: Railway (Easiest - Recommended for Beginners) ⭐

Deploy to the cloud in **5 minutes** with zero server management:

```bash
# 1. Push your code to GitHub
# 2. Go to railway.app and deploy from GitHub
# 3. Add PostgreSQL database (1 click)
# 4. Set environment variables
# 5. Done! Auto HTTPS, scaling, backups included
```

**See: [RAILWAY_QUICKSTART.md](RAILWAY_QUICKSTART.md)** for step-by-step guide.

**Cost**: Free tier ($5/month credit) - Perfect for small projects!

### Option 2: Self-Hosted (Full Control)

Deploy on your own VPS (DigitalOcean, AWS, etc):

```bash
# See PRODUCTION_SETUP.md or PRODUCTION_QUICKSTART.md
./prod-deploy.sh
```

**Cost**: $5-50/month for VPS + your time for maintenance.

### Option 3: Local Development

For testing and development:

```bash
./dev-start.sh
```

---

## Quick Start for Development

The easiest way to get started with local development:

```bash
# Clone the repository
git clone <repository-url>
cd exhibition_project

# Start development environment (this will set up everything)
./dev-start.sh
```

This will:
- Create a `.env` file with development defaults
- Build Docker containers
- Start PostgreSQL database
- Run migrations
- Create a superuser (if needed)
- Start Django development server

Access the application at:
- **Django Admin**: http://localhost:8000/admin
- **Database GUI (Adminer)**: http://localhost:8080

To stop the development environment:
```bash
./dev-stop.sh
```

### Using Makefile Commands (Alternative)

For convenience, you can also use Makefile commands:

```bash
make help           # Show all available commands
make dev-start      # Start development environment
make dev-stop       # Stop development environment
make dev-logs       # View logs
make migrate        # Run migrations
make django-shell   # Open Django shell
make db-shell       # Open database shell
```

For detailed development setup instructions, see [DEV_SETUP.md](DEV_SETUP.md).

## Installation & Setup

### 1. Clone the Repository

```bash
cd /Users/nsharaf/researches/exhibition-app
```

### 2. Environment Configuration

Create a `.env` file in the project root (copy from `.env.example`):

```bash
# Django Settings
SECRET_KEY=your-secret-key-here-change-this-in-production
DEBUG=False
ALLOWED_HOSTS=localhost,127.0.0.1,your-domain.com

# Database
DB_NAME=exhibition_db
DB_USER=exhibition_user
DB_PASSWORD=exhibition_pass_2024
DB_HOST=db
DB_PORT=5432

# Email Configuration (for production)
EMAIL_BACKEND=django.core.mail.backends.smtp.EmailBackend
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USE_TLS=True
EMAIL_HOST_USER=your-email@gmail.com
EMAIL_HOST_PASSWORD=your-app-password
DEFAULT_FROM_EMAIL=your-email@gmail.com

# Application Settings
APP_URL=http://localhost:8000
```

**For Gmail:**
- Enable 2-factor authentication
- Generate an App Password at https://myaccount.google.com/apppasswords
- Use the App Password in `EMAIL_HOST_PASSWORD`

**For Development:**
- Set `EMAIL_BACKEND=django.core.mail.backends.smtp.EmailBackend` to print emails to console instead of sending them

### 3. Build and Run with Docker

```bash
# Build the Docker images
docker-compose build

# Start the services
docker-compose up -d

# Check logs
docker-compose logs -f
```

The application will be available at: http://localhost:8000/admin

### 4. Initialize Database

```bash
# Run migrations
docker-compose exec web python manage.py migrate

# Create a superuser (admin)
docker-compose exec web python manage.py createsuperuser
```

Follow the prompts to create your admin account.

### 5. Access the Application

Navigate to http://localhost:8000/admin and log in with your superuser credentials.

## Usage

### Adding a New Customer (Flow 1)

1. Log in to the admin panel
2. Click on **"Customers"** → **"Add Customer"**
3. Enter customer details:
   - Name
   - Email
   - Phone
4. Click **"Save"**
5. The system will:
   - Generate a unique customer ID
   - Create a QR code
   - Send an email to the customer
   - Display success message

### Adding a Bill (Flow 2)

#### Method 1: From Bill Admin
1. Click on **"Bills"** → **"Add Bill"**
2. Select customer from the dropdown (search by ID or name)
3. Customer information will be displayed
4. Enter the bill amount
5. Add optional description
6. Click **"Save"**

#### Method 2: From Customer Page
1. Click on **"Customers"**
2. Click on a customer name
3. Scroll to the **"Bills"** section at the bottom
4. Add bill(s) inline
5. Click **"Save"**

### Viewing Customer Information

1. Click on **"Customers"** to see the list
2. View customer ID, contact info, number of bills, and total amount
3. Click on any customer to see detailed information and all bills

## Docker Commands

```bash
# Start services
docker-compose up -d

# Stop services
docker-compose down

# View logs
docker-compose logs -f web

# Restart a service
docker-compose restart web

# Run Django commands
docker-compose exec web python manage.py <command>

# Access Django shell
docker-compose exec web python manage.py shell

# Create migrations
docker-compose exec web python manage.py makemigrations

# Apply migrations
docker-compose exec web python manage.py migrate

# Create superuser
docker-compose exec web python manage.py createsuperuser

# Collect static files
docker-compose exec web python manage.py collectstatic --noinput
```

## Database Access

```bash
# Access PostgreSQL directly
docker-compose exec db psql -U exhibition_user -d exhibition_db

# Backup database
docker-compose exec db pg_dump -U exhibition_user exhibition_db > backup.sql

# Restore database
docker-compose exec -T db psql -U exhibition_user exhibition_db < backup.sql
```

## Local Development (Without Docker)

If you prefer to run locally without Docker:

```bash
# Create virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Update .env file with local database settings
# DB_HOST=localhost

# Run migrations
python manage.py migrate

# Create superuser
python manage.py createsuperuser

# Run development server
python manage.py runserver
```

## Production Deployment

### Important Security Settings

Before deploying to production:

1. **Change SECRET_KEY**: Generate a new secret key
   ```python
   python -c 'from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())'
   ```

2. **Set DEBUG=False** in `.env`

3. **Configure ALLOWED_HOSTS**: Add your domain
   ```
   ALLOWED_HOSTS=yourdomain.com,www.yourdomain.com
   ```

4. **Use HTTPS**: Configure SSL/TLS certificates

5. **Strong Database Password**: Change `DB_PASSWORD`

6. **Configure Email**: Set up production email service

7. **Regular Backups**: Schedule database backups

### Production Docker Compose

For production, consider:
- Using Docker secrets for sensitive data
- Setting up reverse proxy (Nginx)
- Configuring SSL certificates
- Setting up monitoring and logging
- Using managed PostgreSQL service

## Troubleshooting

### Email not sending
- Check email configuration in `.env`
- Verify SMTP credentials
- Check firewall settings
- For Gmail, ensure App Password is used
- Use `EMAIL_BACKEND=django.core.mail.backends.smtp.EmailBackend` for testing

### Database connection issues
- Ensure PostgreSQL container is running: `docker-compose ps`
- Check database credentials in `.env`
- Wait for database to be ready (health check)

### QR codes not displaying
- Check media directory permissions
- Ensure `MEDIA_ROOT` and `MEDIA_URL` are configured
- Verify `qrcodes/` directory exists in `media/`

### Permission denied errors
- Run: `docker-compose down -v` to remove volumes
- Rebuild: `docker-compose build --no-cache`
- Start again: `docker-compose up -d`

## API Endpoints

Currently, the application only provides an admin interface. No public APIs are exposed.

Admin URL: `/admin/`

## Security Features

- Admin-only access (no public registration)
- CSRF protection enabled
- Secure password hashing
- SQL injection protection (Django ORM)
- XSS protection
- Secure cookie settings in production
- HTTPS enforcement in production

## Models

### Customer Model
- `customer_id`: Unique 8-character alphanumeric ID
- `name`: Customer's full name
- `email`: Email address
- `phone`: Contact phone number
- `qr_code`: QR code image file
- `email_sent`: Email status flag
- `created_at`: Timestamp
- `updated_at`: Timestamp

### Bill Model
- `customer`: Foreign key to Customer
- `amount`: Decimal amount
- `description`: Optional bill description
- `created_at`: Timestamp
- `created_by`: Admin username

## Support

For issues or questions, please contact the development team.

## License

Proprietary - All rights reserved.

