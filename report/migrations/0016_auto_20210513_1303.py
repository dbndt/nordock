# Generated by Django 3.2 on 2021-05-13 03:03

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('report', '0015_auto_20210403_1837'),
    ]

    operations = [
        migrations.AddField(
            model_name='billofmaterialsreport',
            name='filename_pattern',
            field=models.CharField(default='report.pdf', help_text='Pattern for generating report filenames', max_length=100, verbose_name='Filename Pattern'),
        ),
        migrations.AddField(
            model_name='buildreport',
            name='filename_pattern',
            field=models.CharField(default='report.pdf', help_text='Pattern for generating report filenames', max_length=100, verbose_name='Filename Pattern'),
        ),
        migrations.AddField(
            model_name='purchaseorderreport',
            name='filename_pattern',
            field=models.CharField(default='report.pdf', help_text='Pattern for generating report filenames', max_length=100, verbose_name='Filename Pattern'),
        ),
        migrations.AddField(
            model_name='salesorderreport',
            name='filename_pattern',
            field=models.CharField(default='report.pdf', help_text='Pattern for generating report filenames', max_length=100, verbose_name='Filename Pattern'),
        ),
        migrations.AddField(
            model_name='testreport',
            name='filename_pattern',
            field=models.CharField(default='report.pdf', help_text='Pattern for generating report filenames', max_length=100, verbose_name='Filename Pattern'),
        ),
    ]
