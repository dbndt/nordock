# Generated by Django 3.0.5 on 2020-05-16 09:55

from django.conf import settings
from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
        ('stock', '0039_auto_20200513_0016'),
    ]

    operations = [
        migrations.CreateModel(
            name='StockItemTestResult',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('test', models.CharField(help_text='Test name', max_length=100, verbose_name='Test')),
                ('result', models.BooleanField(default=False, help_text='Test result', verbose_name='Result')),
                ('value', models.CharField(blank=True, help_text='Test output value', max_length=500, verbose_name='Value')),
                ('date', models.DateTimeField(auto_now_add=True)),
                ('attachment', models.ForeignKey(blank=True, help_text='Test result attachment', null=True, on_delete=django.db.models.deletion.SET_NULL, to='stock.StockItemAttachment', verbose_name='Attachment')),
                ('stock_item', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='test_results', to='stock.StockItem')),
                ('user', models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.SET_NULL, to=settings.AUTH_USER_MODEL)),
            ],
        ),
    ]
