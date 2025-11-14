#!/usr/bin/env python
"""
Email Configuration Test Script
Run this inside the container to test email settings
"""

import os
import django

# Setup Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'exhibition_project.settings')
django.setup()

from django.conf import settings
from django.core.mail import send_mail
from django.core.mail import EmailMessage
import sys

print("=" * 60)
print("EMAIL CONFIGURATION TEST")
print("=" * 60)
print()

# Show current settings
print("📧 Current Email Settings:")
print("-" * 60)
print(f"EMAIL_BACKEND:      {settings.EMAIL_BACKEND}")
print(f"EMAIL_HOST:         {settings.EMAIL_HOST}")
print(f"EMAIL_PORT:         {settings.EMAIL_PORT}")
print(f"EMAIL_USE_TLS:      {settings.EMAIL_USE_TLS}")
print(f"EMAIL_HOST_USER:    {settings.EMAIL_HOST_USER}")
print(f"EMAIL_HOST_PASSWORD: {'***' + settings.EMAIL_HOST_PASSWORD[-4:] if settings.EMAIL_HOST_PASSWORD else 'NOT SET'}")
print(f"DEFAULT_FROM_EMAIL: {settings.DEFAULT_FROM_EMAIL}")
print()

# Check if using console backend
if 'console' in settings.EMAIL_BACKEND.lower():
    print("⚠️  WARNING: Using CONSOLE backend!")
    print("   Emails will be printed to console, not sent.")
    print("   To send real emails, update your .env file:")
    print("   EMAIL_BACKEND=django.core.mail.backends.smtp.EmailBackend")
    print()
    sys.exit(0)

# Check if credentials are set
if not settings.EMAIL_HOST_USER or not settings.EMAIL_HOST_PASSWORD:
    print("❌ ERROR: Email credentials not set!")
    print("   Please set EMAIL_HOST_USER and EMAIL_HOST_PASSWORD in .env")
    sys.exit(1)

print("✅ Configuration looks good!")
print()

# Ask for test email
test_email = input("Enter email address to send test to (or press Enter to skip): ").strip()

if test_email:
    print()
    print(f"📤 Sending test email to {test_email}...")
    print()
    
    try:
        # Send test email
        send_mail(
            subject='Test Email from Exhibition Project',
            message='This is a test email. If you received this, your email configuration is working!',
            from_email=settings.DEFAULT_FROM_EMAIL,
            recipient_list=[test_email],
            fail_silently=False,
        )
        print("✅ Email sent successfully!")
        print()
        print("📬 Check your inbox (and spam folder) for the test email.")
        
    except Exception as e:
        print(f"❌ Error sending email: {e}")
        print()
        print("Common issues:")
        print("1. Wrong app password - verify in .env file")
        print("2. Gmail blocking - check for security alert in your Gmail")
        print("3. Network issues - check your internet connection")
        print("4. Wrong email address - verify EMAIL_HOST_USER in .env")
        sys.exit(1)
else:
    print("Skipping email test.")

print()
print("=" * 60)
print("Test complete!")
print("=" * 60)

