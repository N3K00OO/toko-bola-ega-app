# main/forms/forms.py
from django import forms
from main.models import Product

class ProductForm(forms.ModelForm):
    category_custom = forms.CharField(
        required=False,
        label="If Misc/Others, specify",
        widget=forms.TextInput(attrs={
            "class": "mt-1 w-full px-3 py-2 rounded-lg border border-gray-300 "
                     "focus:outline-none focus:ring-2 focus:ring-violet-400",
            "placeholder": "e.g., Whistles, Cones, Med Kits",
            "id": "id_category_custom",
        }),
    )

    class Meta:
        model = Product
        fields = ["name", "brand", "price", "thumbnails", "description",
                  "category", "category_custom", "is_featured"]
        widgets = {
            "name": forms.TextInput(attrs={"class": "mt-1 w-full px-3 py-2 rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-violet-400"}),
            "brand": forms.TextInput(attrs={"class": "mt-1 w-full px-3 py-2 rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-violet-400"}),
            "price": forms.NumberInput(attrs={"class": "mt-1 w-full px-3 py-2 rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-violet-400"}),
            "thumbnails": forms.URLInput(attrs={"class": "mt-1 w-full px-3 py-2 rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-violet-400"}),
            "description": forms.Textarea(attrs={"rows": 4, "class": "mt-1 w-full px-3 py-2 rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-violet-400"}),
            "category": forms.Select(attrs={"class": "mt-1 w-full px-3 py-2 rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-violet-400",
                                            "id": "id_category"}),
            "is_featured": forms.CheckboxInput(attrs={"class": "h-4 w-4 text-violet-600"}),
        }
