# Generated by Django 2.2.9 on 2020-02-03 10:07

import InvenTree.validators
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('part', '0027_auto_20200202_1024'),
    ]

    operations = [
        migrations.AlterField(
            model_name='part',
            name='IPN',
            field=models.CharField(blank=True, help_text='Internal Part Number', max_length=100, validators=[InvenTree.validators.validate_part_ipn]),
        ),
    ]
