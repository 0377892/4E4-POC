from django.contrib import admin
from .models import Category

@admin.register(Category)
class CategoryAdmin(admin.ModelAdmin):
    list_display = ('key', 'label_en', 'label_fr')
    search_fields = ('key', 'label_en', 'label_fr')