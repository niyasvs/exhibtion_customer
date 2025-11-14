"""
Models for Customer and Bill management.
"""
from django.db import models
from django.core.validators import EmailValidator
import uuid
from django.utils import timezone


class Customer(models.Model):
    """
    Customer model to store customer information.
    """
    # Unique customer ID (8-character alphanumeric)
    customer_id = models.CharField(
        max_length=8, 
        unique=True, 
        editable=False,
        db_index=True,
        help_text="Unique 8-character customer ID"
    )
    
    # Customer details
    name = models.CharField(
        max_length=255,
        help_text="Full name of the customer"
    )
    
    email = models.EmailField(
        validators=[EmailValidator()],
        help_text="Email address for communication"
    )
    
    phone = models.CharField(
        max_length=20,
        help_text="Contact phone number"
    )
    
    # Metadata
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    # Email sent status
    email_sent = models.BooleanField(
        default=False,
        help_text="Whether welcome email with QR code has been sent"
    )

    class Meta:
        ordering = ['-created_at']
        verbose_name = 'Customer'
        verbose_name_plural = 'Customers'

    def __str__(self):
        return f"{self.name} ({self.customer_id})"

    def save(self, *args, **kwargs):
        """Generate unique customer ID before saving."""
        if not self.customer_id:
            self.customer_id = self.generate_unique_id()
        super().save(*args, **kwargs)

    @staticmethod
    def generate_unique_id():
        """Generate a unique 8-character alphanumeric ID."""
        while True:
            # Generate 8-character UUID-based ID
            new_id = str(uuid.uuid4().hex)[:8].upper()
            if not Customer.objects.filter(customer_id=new_id).exists():
                return new_id

    def get_total_bills(self):
        """Calculate total amount of all bills for this customer."""
        return self.bills.aggregate(total=models.Sum('amount'))['total'] or 0

    def get_bill_count(self):
        """Get the number of bills for this customer."""
        return self.bills.count()


class Bill(models.Model):
    """
    Bill model to store billing information for customers.
    """
    customer = models.ForeignKey(
        Customer,
        on_delete=models.CASCADE,
        related_name='bills',
        help_text="Customer associated with this bill"
    )
    
    amount = models.DecimalField(
        max_digits=10,
        decimal_places=2,
        help_text="Bill amount"
    )
    
    description = models.TextField(
        blank=True,
        null=True,
        help_text="Optional description of the bill"
    )
    
    created_at = models.DateTimeField(auto_now_add=True)
    created_by = models.CharField(
        max_length=255,
        blank=True,
        null=True,
        help_text="Admin user who created this bill"
    )

    class Meta:
        ordering = ['-created_at']
        verbose_name = 'Bill'
        verbose_name_plural = 'Bills'

    def __str__(self):
        return f"Bill for {self.customer.name} - ${self.amount}"

