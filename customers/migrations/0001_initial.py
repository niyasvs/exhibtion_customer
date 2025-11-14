# Generated migration

from django.db import migrations, models
import django.core.validators


class Migration(migrations.Migration):

    initial = True

    dependencies = [
    ]

    operations = [
        migrations.CreateModel(
            name='Customer',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('customer_id', models.CharField(db_index=True, editable=False, help_text='Unique 8-character customer ID', max_length=8, unique=True)),
                ('name', models.CharField(help_text='Full name of the customer', max_length=255)),
                ('email', models.EmailField(help_text='Email address for communication', max_length=254, validators=[django.core.validators.EmailValidator()])),
                ('phone', models.CharField(help_text='Contact phone number', max_length=20)),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('updated_at', models.DateTimeField(auto_now=True)),
                ('email_sent', models.BooleanField(default=False, help_text='Whether welcome email with QR code has been sent')),
            ],
            options={
                'verbose_name': 'Customer',
                'verbose_name_plural': 'Customers',
                'ordering': ['-created_at'],
            },
        ),
        migrations.CreateModel(
            name='Bill',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('amount', models.DecimalField(decimal_places=2, help_text='Bill amount', max_digits=10)),
                ('description', models.TextField(blank=True, help_text='Optional description of the bill', null=True)),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('created_by', models.CharField(blank=True, help_text='Admin user who created this bill', max_length=255, null=True)),
                ('customer', models.ForeignKey(help_text='Customer associated with this bill', on_delete=models.deletion.CASCADE, related_name='bills', to='customers.customer')),
            ],
            options={
                'verbose_name': 'Bill',
                'verbose_name_plural': 'Bills',
                'ordering': ['-created_at'],
            },
        ),
    ]

