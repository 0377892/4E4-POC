from django.db import models

class Category(models.Model):
    key      = models.CharField(max_length=50, unique=True)
    label_en = models.CharField(max_length=100)
    label_fr = models.CharField(max_length=100)

    def __str__(self):
        return self.label_en