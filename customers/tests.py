"""
Tests for customers app.
"""
from django.test import TestCase
from django.contrib.auth.models import User
from .models import Customer, Bill
from .utils import generate_qr_code


class CustomerModelTest(TestCase):
    """Test Customer model."""
    
    def setUp(self):
        """Set up test data."""
        self.customer = Customer.objects.create(
            name="Test Customer",
            email="test@example.com",
            phone="+1234567890"
        )
    
    def test_customer_creation(self):
        """Test customer is created with unique ID."""
        self.assertIsNotNone(self.customer.customer_id)
        self.assertEqual(len(self.customer.customer_id), 8)
        self.assertEqual(self.customer.name, "Test Customer")
    
    def test_customer_id_uniqueness(self):
        """Test customer IDs are unique."""
        customer2 = Customer.objects.create(
            name="Another Customer",
            email="another@example.com",
            phone="+0987654321"
        )
        self.assertNotEqual(self.customer.customer_id, customer2.customer_id)
    
    def test_get_total_bills(self):
        """Test total bills calculation."""
        Bill.objects.create(customer=self.customer, amount=100.00)
        Bill.objects.create(customer=self.customer, amount=50.00)
        self.assertEqual(self.customer.get_total_bills(), 150.00)
    
    def test_get_bill_count(self):
        """Test bill count."""
        Bill.objects.create(customer=self.customer, amount=100.00)
        Bill.objects.create(customer=self.customer, amount=50.00)
        self.assertEqual(self.customer.get_bill_count(), 2)


class BillModelTest(TestCase):
    """Test Bill model."""
    
    def setUp(self):
        """Set up test data."""
        self.customer = Customer.objects.create(
            name="Test Customer",
            email="test@example.com",
            phone="+1234567890"
        )
    
    def test_bill_creation(self):
        """Test bill is created correctly."""
        bill = Bill.objects.create(
            customer=self.customer,
            amount=100.00,
            description="Test bill"
        )
        self.assertEqual(bill.customer, self.customer)
        self.assertEqual(bill.amount, 100.00)
        self.assertEqual(bill.description, "Test bill")
    
    def test_multiple_bills_per_customer(self):
        """Test customer can have multiple bills."""
        Bill.objects.create(customer=self.customer, amount=100.00)
        Bill.objects.create(customer=self.customer, amount=200.00)
        Bill.objects.create(customer=self.customer, amount=300.00)
        self.assertEqual(self.customer.bills.count(), 3)


class QRCodeUtilTest(TestCase):
    """Test QR code generation utility."""
    
    def test_generate_qr_code(self):
        """Test QR code generation."""
        customer_id = "TEST1234"
        qr_file = generate_qr_code(customer_id)
        self.assertIsNotNone(qr_file)
        self.assertTrue(qr_file.name.startswith('qr_'))
        self.assertTrue(qr_file.name.endswith('.png'))

