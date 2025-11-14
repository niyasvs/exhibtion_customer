# Testing Guide

This guide covers how to test the Exhibition Customer Management System.

## Running Tests

### Using Docker

```bash
# Run all tests
docker-compose exec web python manage.py test

# Run with verbosity
docker-compose exec web python manage.py test --verbosity=2

# Run specific app tests
docker-compose exec web python manage.py test customers

# Run specific test class
docker-compose exec web python manage.py test customers.tests.CustomerModelTest

# Run specific test method
docker-compose exec web python manage.py test customers.tests.CustomerModelTest.test_customer_creation
```

### Local Development

```bash
# Activate virtual environment
source venv/bin/activate

# Run tests
python manage.py test

# With coverage
pip install coverage
coverage run --source='.' manage.py test
coverage report
coverage html
```

## Manual Testing Checklist

### Flow 1: Customer Registration

#### Test Case 1: Create New Customer
- [ ] Navigate to Admin → Customers → Add Customer
- [ ] Enter customer details:
  - Name: "John Doe"
  - Email: "john@example.com"
  - Phone: "+1234567890"
- [ ] Click Save
- [ ] Verify success message appears
- [ ] Verify unique customer ID is generated (8 characters)
- [ ] Verify QR code is created
- [ ] Check Docker logs for email: `docker-compose logs web`
- [ ] Verify email contains customer ID and QR code attachment

#### Test Case 2: Customer ID Uniqueness
- [ ] Create multiple customers
- [ ] Verify each customer has a unique ID
- [ ] Verify IDs are 8 characters long
- [ ] Verify IDs contain only uppercase alphanumeric characters

#### Test Case 3: QR Code Generation
- [ ] Create a customer
- [ ] View customer in admin
- [ ] Verify QR code preview is displayed
- [ ] Download QR code image
- [ ] Scan QR code with a QR reader
- [ ] Verify it contains the customer ID

#### Test Case 4: Email Sending
- [ ] Configure SMTP settings in .env
- [ ] Create a customer with your email
- [ ] Check your inbox
- [ ] Verify email subject contains customer ID
- [ ] Verify email body contains customer name and ID
- [ ] Verify QR code is attached
- [ ] Verify QR code attachment can be opened

### Flow 2: Billing Management

#### Test Case 5: Add Bill from Bill Admin
- [ ] Navigate to Admin → Bills → Add Bill
- [ ] Select a customer from dropdown
- [ ] Verify customer information is displayed
- [ ] Enter amount: 150.00
- [ ] Enter description: "Test bill"
- [ ] Click Save
- [ ] Verify success message appears
- [ ] Verify bill appears in bill list

#### Test Case 6: Add Multiple Bills
- [ ] Add 3 bills for the same customer:
  - Bill 1: $100.00
  - Bill 2: $200.00
  - Bill 3: $300.00
- [ ] Navigate to Customers list
- [ ] Verify "Total Billing" shows $600.00
- [ ] Verify "Number of Bills" shows 3
- [ ] Click on the customer
- [ ] Verify all 3 bills are listed

#### Test Case 7: Add Bill from Customer Page
- [ ] Navigate to a customer detail page
- [ ] Scroll to Bills section
- [ ] Add bill inline:
  - Amount: 75.00
  - Description: "Inline bill"
- [ ] Click Save
- [ ] Verify bill is added
- [ ] Verify totals are updated

#### Test Case 8: Search and Filter
- [ ] Go to Bills list
- [ ] Search by customer ID
- [ ] Verify correct bills appear
- [ ] Search by customer name
- [ ] Verify correct bills appear
- [ ] Filter by date
- [ ] Verify filtering works

### Security Testing

#### Test Case 9: Admin Access Only
- [ ] Log out of admin
- [ ] Try to access /admin/ without login
- [ ] Verify redirect to login page
- [ ] Try to access any admin URL without authentication
- [ ] Verify access is denied

#### Test Case 10: Non-Admin User
- [ ] Create a non-staff user:
  ```bash
  docker-compose exec web python manage.py shell
  from django.contrib.auth.models import User
  user = User.objects.create_user('testuser', 'test@example.com', 'testpass123')
  user.save()
  exit()
  ```
- [ ] Try to log in as this user
- [ ] Verify access is denied (user is not staff)

### Data Validation

#### Test Case 11: Email Validation
- [ ] Try to create customer with invalid email: "notanemail"
- [ ] Verify error message appears
- [ ] Try valid email: "valid@example.com"
- [ ] Verify customer is created

#### Test Case 12: Required Fields
- [ ] Try to save customer without name
- [ ] Verify error message
- [ ] Try to save customer without email
- [ ] Verify error message
- [ ] Try to save customer without phone
- [ ] Verify error message

#### Test Case 13: Bill Amount Validation
- [ ] Try to create bill with negative amount
- [ ] Verify validation works
- [ ] Try to create bill with very large amount (99999999.99)
- [ ] Verify it's accepted
- [ ] Try to create bill with too many decimal places (100.123)
- [ ] Verify it's rounded to 2 decimal places

### Performance Testing

#### Test Case 14: Bulk Customer Creation
- [ ] Create 100 customers using Django shell:
  ```python
  docker-compose exec web python manage.py shell
  from customers.models import Customer
  for i in range(100):
      Customer.objects.create(
          name=f"Customer {i}",
          email=f"customer{i}@example.com",
          phone=f"+123456{i:04d}"
      )
  ```
- [ ] Verify all customers have unique IDs
- [ ] Check admin list page loads quickly
- [ ] Test search functionality with many records

#### Test Case 15: Many Bills Per Customer
- [ ] Create a customer
- [ ] Add 50 bills to the same customer
- [ ] View customer detail page
- [ ] Verify page loads within reasonable time
- [ ] Verify totals are calculated correctly

### Integration Testing

#### Test Case 16: Complete Workflow
- [ ] Create new customer "Alice Smith"
- [ ] Verify email sent (check logs or inbox)
- [ ] Save QR code from email
- [ ] Scan QR code to get customer ID
- [ ] Add bill using the customer ID from QR code
- [ ] Add 2 more bills
- [ ] Verify customer page shows correct totals
- [ ] Verify all bills are listed

### Database Testing

#### Test Case 17: Database Persistence
- [ ] Create customers and bills
- [ ] Stop Docker containers: `docker-compose down`
- [ ] Start containers: `docker-compose up -d`
- [ ] Verify all data persists
- [ ] Verify QR codes are still accessible

#### Test Case 18: Database Relationships
- [ ] Create a customer with bills
- [ ] Try to delete the customer
- [ ] Verify cascade delete warning
- [ ] Delete the customer
- [ ] Verify all associated bills are also deleted

## Automated Testing

### Unit Tests

```bash
# Run unit tests
docker-compose exec web python manage.py test customers.tests
```

### Coverage Report

```bash
# Install coverage
docker-compose exec web pip install coverage

# Run with coverage
docker-compose exec web coverage run --source='.' manage.py test

# Generate report
docker-compose exec web coverage report

# Generate HTML report
docker-compose exec web coverage html

# View report (copy to local machine)
docker cp exhibition-app_web_1:/app/htmlcov ./coverage_report
open coverage_report/index.html
```

## Load Testing

### Using Apache Bench

```bash
# Install Apache Bench
brew install httpd  # macOS
sudo apt-get install apache2-utils  # Ubuntu

# Test admin login page
ab -n 1000 -c 10 http://localhost:8000/admin/

# Test with authentication (after getting session cookie)
ab -n 1000 -c 10 -C "sessionid=<your-session-id>" http://localhost:8000/admin/customers/customer/
```

### Using Locust

Create `locustfile.py`:

```python
from locust import HttpUser, task, between

class AdminUser(HttpUser):
    wait_time = between(1, 3)
    
    def on_start(self):
        # Login
        self.client.post("/admin/login/", {
            "username": "admin",
            "password": "admin123"
        })
    
    @task
    def view_customers(self):
        self.client.get("/admin/customers/customer/")
    
    @task
    def view_bills(self):
        self.client.get("/admin/customers/bill/")
```

Run:
```bash
pip install locust
locust -f locustfile.py
# Open http://localhost:8089
```

## Test Data

### Creating Test Data

```bash
docker-compose exec web python manage.py shell
```

```python
from customers.models import Customer, Bill
from decimal import Decimal

# Create 10 test customers
customers = []
for i in range(1, 11):
    customer = Customer.objects.create(
        name=f"Test Customer {i}",
        email=f"customer{i}@test.com",
        phone=f"+1234567{i:03d}"
    )
    customers.append(customer)
    print(f"Created: {customer.name} - ID: {customer.customer_id}")

# Add random bills
import random
for customer in customers:
    num_bills = random.randint(1, 5)
    for _ in range(num_bills):
        amount = Decimal(random.uniform(10, 500)).quantize(Decimal('0.01'))
        Bill.objects.create(
            customer=customer,
            amount=amount,
            description=f"Test bill for {customer.name}"
        )
    print(f"Added {num_bills} bills for {customer.name}")

print("\nTest data created successfully!")
```

### Cleaning Test Data

```bash
docker-compose exec web python manage.py shell
```

```python
from customers.models import Customer, Bill

# Delete all test data
Customer.objects.filter(email__contains="@test.com").delete()
Bill.objects.all().delete()

print("Test data cleaned!")
```

## Troubleshooting Tests

### Tests failing with database errors
```bash
# Reset database
docker-compose down -v
docker-compose up -d
docker-compose exec web python manage.py migrate
docker-compose exec web python manage.py test
```

### QR code tests failing
```bash
# Ensure media directory exists and is writable
docker-compose exec web mkdir -p /app/media/qrcodes
docker-compose exec web chmod -R 777 /app/media
```

### Email tests failing
```bash
# Use console backend for testing
# In .env:
EMAIL_BACKEND=django.core.mail.backends.smtp.EmailBackend
```

## Continuous Integration

Example GitHub Actions workflow (`.github/workflows/test.yml`):

```yaml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    
    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_DB: test_db
          POSTGRES_USER: test_user
          POSTGRES_PASSWORD: test_pass
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
    
    steps:
    - uses: actions/checkout@v2
    
    - name: Set up Python
      uses: actions/setup-python@v2
      with:
        python-version: 3.11
    
    - name: Install dependencies
      run: |
        pip install -r requirements.txt
    
    - name: Run tests
      env:
        DB_NAME: test_db
        DB_USER: test_user
        DB_PASSWORD: test_pass
        DB_HOST: localhost
        DB_PORT: 5432
      run: |
        python manage.py test
```

## Test Results Documentation

After testing, document results:

- [ ] All unit tests passing
- [ ] All manual test cases completed
- [ ] Performance benchmarks recorded
- [ ] No critical bugs found
- [ ] Email functionality verified
- [ ] QR code generation working
- [ ] Database operations correct
- [ ] Security measures in place

## Next Steps

After successful testing:
1. Review any failing tests
2. Fix identified issues
3. Re-test after fixes
4. Document any known limitations
5. Proceed with deployment

