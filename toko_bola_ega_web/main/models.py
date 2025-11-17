# main/models.py
from django.db import models
from django.contrib.auth.models import User
from django.core.validators import MinValueValidator
from django.db.models import F, Index
import uuid

# Single source of truth for known categories (codes → labels)
CATEGORY_CHOICES = [
    ("jerseys", "Jerseys"),
    ("balls", "Balls"),
    ("trainers", "Trainers"),
    ("protectors", "Protectors"),
    ("clearance", "Clearance"),
    ("misc", "Misc / Others"),
]


class Product(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, null=True)

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    name = models.CharField(max_length=100)

    # Rupiah has no cents; PositiveInteger is fine. Use DecimalField if you ever need fractional.
    price = models.PositiveIntegerField(validators=[MinValueValidator(0)])

    # Make optional so forms/APIs don’t choke on empty values
    description = models.TextField(blank=True)
    thumbnails = models.URLField(blank=True)

    # Store the CODE (e.g., "jerseys"). If you plan to allow truly custom strings,
    category = models.CharField(max_length=32, choices=CATEGORY_CHOICES)

    is_featured = models.BooleanField(default=False)
    brand = models.CharField(max_length=50, default="Unknown")
    created_at = models.DateTimeField(auto_now_add=True)
    views = models.PositiveIntegerField(default=0)

    class Meta:
        ordering = ["-created_at"]
        indexes = [
            Index(fields=["-created_at"]),
            Index(fields=["category"]),
            Index(fields=["is_featured"]),
            # Index(fields=["user"]),
        ]

    def __str__(self):
        return f"{self.name} ({self.get_category_display()})"

    @classmethod
    def categories(cls):
        return CATEGORY_CHOICES

    def increment_views(self):
        """Atomic, race-safe view increment (no lost updates)."""
        type(self).objects.filter(pk=self.pk).update(views=F("views") + 1)
        self.refresh_from_db(fields=["views"])

    def as_dict(self, request_user=None):
        owner = self.user
        owner_display = None
        if owner:
            owner_display = owner.get_full_name() or owner.username

        return {
            "id": str(self.id),
            "name": self.name,
            "brand": self.brand,
            "category": self.category,  # code, e.g., "jerseys"
            "price": self.price,
            "description": self.description,
            "thumbnails": self.thumbnails,
            "is_featured": self.is_featured,
            "created_at": self.created_at.isoformat() if self.created_at else None,
            "views": self.views,
            "is_owner": (self.user_id == getattr(request_user, "id", None)),
            "owner_username": owner.username if owner else None,
            "owner_name": owner_display,
        }

    # Optional: convenience for templates
    def get_absolute_url(self):
        from django.urls import reverse
        return reverse("main:show_product", args=[str(self.pk)])
