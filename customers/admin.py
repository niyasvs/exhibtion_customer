"""
Admin interface for Customer and Bill management.
"""
from django.contrib import admin
from django.utils.html import format_html
from django.contrib import messages
from django.http import HttpResponse
from .models import Customer, Bill
from .utils import generate_qr_code, send_customer_welcome_email, export_customers_to_excel


class BillInline(admin.TabularInline):
    """Inline admin for bills within customer admin."""
    model = Bill
    extra = 1
    fields = ('amount', 'description', 'created_at')
    readonly_fields = ('created_at',)
    can_delete = True


@admin.register(Customer)
class CustomerAdmin(admin.ModelAdmin):
    """
    Admin interface for Customer model.
    Handles Flow 1: Creating customers, generating IDs, QR codes, and sending emails.
    """
    list_display = (
        'customer_id', 
        'name', 
        'email', 
        'phone', 
        'email_sent_status',
        'bill_count',
        'total_amount',
        'created_at'
    )
    
    list_filter = ('email_sent', 'created_at')
    search_fields = ('customer_id', 'name', 'email', 'phone')
    readonly_fields = (
        'customer_id', 
        'created_at', 
        'updated_at', 
        'email_sent',
        'bill_count',
        'total_amount'
    )
    
    fieldsets = (
        ('Customer Information', {
            'fields': ('customer_id', 'name', 'email', 'phone')
        }),
        ('Email Status', {
            'fields': ('email_sent',),
            'description': 'QR code is automatically generated and sent via email (not saved to database)'
        }),
        ('Billing Summary', {
            'fields': ('bill_count', 'total_amount')
        }),
        ('Metadata', {
            'fields': ('created_at', 'updated_at'),
            'classes': ('collapse',)
        }),
    )
    
    inlines = [BillInline]
    actions = ['export_to_excel']

    def export_to_excel(self, request, queryset):
        """
        Export selected customers with their billing information to Excel.
        """
        # Generate Excel file
        excel_file = export_customers_to_excel(queryset)
        
        # Create HTTP response with Excel file
        response = HttpResponse(
            excel_file,
            content_type='application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
        )
        response['Content-Disposition'] = 'attachment; filename="customers_export.xlsx"'
        
        # Show success message
        self.message_user(
            request,
            f'Successfully exported {queryset.count()} customer(s) to Excel.',
            messages.SUCCESS
        )
        
        return response
    
    export_to_excel.short_description = "Export selected customers to Excel"

    def save_model(self, request, obj, form, change):
        """
        Override save to send email with QR code for new customers.
        QR code is generated on-the-fly and not saved to database.
        """
        is_new = obj.pk is None
        
        # Save the object first to get the customer_id
        super().save_model(request, obj, form, change)
        
        if is_new:
            # Send welcome email with QR code (generated on-the-fly)
            email_sent = send_customer_welcome_email(obj)
            
            if email_sent:
                obj.email_sent = True
                obj.save(update_fields=['email_sent'])
                messages.success(
                    request,
                    f'Customer {obj.name} created successfully! '
                    f'Email sent to {obj.email} with customer ID: {obj.customer_id}'
                )
            else:
                messages.warning(
                    request,
                    f'Customer {obj.name} created with ID: {obj.customer_id}, '
                    f'but email could not be sent. Please check email configuration.'
                )

    def email_sent_status(self, obj):
        """Display email sent status with icons."""
        if obj.email_sent:
            return format_html(
                '<span style="color: green;">✓ Sent</span>'
            )
        return format_html(
            '<span style="color: red;">✗ Not Sent</span>'
        )
    email_sent_status.short_description = 'Email Status'

    def bill_count(self, obj):
        """Display number of bills for the customer."""
        return obj.get_bill_count()
    bill_count.short_description = 'Number of Bills'

    def total_amount(self, obj):
        """Display total billing amount for the customer."""
        total = obj.get_total_bills()
        return f'${total:,.2f}'
    total_amount.short_description = 'Total Billing'


@admin.register(Bill)
class BillAdmin(admin.ModelAdmin):
    """
    Admin interface for Bill model.
    Handles Flow 2: Entering customer ID, fetching info, and adding bills.
    """
    list_display = (
        'id',
        'customer_id_display',
        'customer_name',
        'customer_email',
        'amount',
        'created_at',
        'created_by'
    )
    
    list_filter = ('created_at',)
    search_fields = (
        'customer__customer_id',
        'customer__name',
        'customer__email',
        'description'
    )
    
    readonly_fields = (
        'created_at',
        'customer_info_display'
    )
    
    fieldsets = (
        ('Customer Information', {
            'fields': ('customer', 'customer_info_display'),
            'description': 'Select customer by their Customer ID or name'
        }),
        ('Bill Details', {
            'fields': ('amount', 'description')
        }),
        ('Metadata', {
            'fields': ('created_at', 'created_by'),
            'classes': ('collapse',)
        }),
    )

    autocomplete_fields = []  # We'll use raw_id_fields instead for better search

    def get_form(self, request, obj=None, **kwargs):
        """Customize form to help with customer selection."""
        form = super().get_form(request, obj, **kwargs)
        # Add help text for customer field
        if 'customer' in form.base_fields:
            form.base_fields['customer'].help_text = (
                'Search by Customer ID or Name. '
                'Customer information will be displayed below after selection.'
            )
        return form

    def save_model(self, request, obj, form, change):
        """Save bill and record who created it."""
        if not change:  # New bill
            obj.created_by = request.user.username
        super().save_model(request, obj, form, change)
        
        if not change:
            messages.success(
                request,
                f'Bill of ${obj.amount} added for customer {obj.customer.name} '
                f'(ID: {obj.customer.customer_id})'
            )

    def customer_id_display(self, obj):
        """Display customer ID."""
        return obj.customer.customer_id
    customer_id_display.short_description = 'Customer ID'

    def customer_name(self, obj):
        """Display customer name."""
        return obj.customer.name
    customer_name.short_description = 'Customer Name'

    def customer_email(self, obj):
        """Display customer email."""
        return obj.customer.email
    customer_email.short_description = 'Customer Email'

    def customer_info_display(self, obj):
        """Display detailed customer information."""
        if obj.customer:
            customer = obj.customer
            return format_html(
                '<div style="background-color: #f0f0f0; padding: 15px; '
                'border-radius: 5px; margin: 10px 0;">'
                '<h3 style="margin-top: 0;">Customer Details</h3>'
                '<p><strong>Customer ID:</strong> {}</p>'
                '<p><strong>Name:</strong> {}</p>'
                '<p><strong>Email:</strong> {}</p>'
                '<p><strong>Phone:</strong> {}</p>'
                '<p><strong>Total Bills:</strong> {}</p>'
                '<p><strong>Total Amount:</strong> ${:,.2f}</p>'
                '</div>',
                customer.customer_id,
                customer.name,
                customer.email,
                customer.phone,
                customer.get_bill_count(),
                customer.get_total_bills()
            )
        return "No customer selected"
    customer_info_display.short_description = 'Customer Information'


# Customize admin site
admin.site.site_header = "Exhibition Customer Management System"
admin.site.site_title = "Exhibition Admin"
admin.site.index_title = "Manage Customers and Billing"

