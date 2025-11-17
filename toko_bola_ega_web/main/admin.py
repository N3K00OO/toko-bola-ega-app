from django.contrib import admin
from .models import Product

@admin.register(Product)
class ProductAdmin(admin.ModelAdmin):
    list_display = ("name", "brand", "category", "price", "is_featured", "created_at", "views")
    list_filter = ("is_featured", "category", "brand")
    search_fields = ("name", "brand", "category", "description")
