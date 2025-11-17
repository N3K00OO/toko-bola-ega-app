from django.urls import path
from .views import (
    delete_product, edit_product, show_main, create_product, show_product,
    show_xml, show_json, show_xml_by_id, show_json_by_id, 
    register, login_user, logout_user
)
from main import views

app_name = "main"

urlpatterns = [
    path("", show_main, name="show_main"),
    path("create/", create_product, name="create_product"),
    path("product/<str:id>/", show_product, name="show_product"),
    path("xml/", show_xml, name="show_xml"),
    path("json/", show_json, name="show_json"),
    path("xml/<str:id>/", show_xml_by_id, name="show_xml_by_id"),
    path("json/<str:id>/", show_json_by_id, name="show_json_by_id"),
    path('register/', register, name='register'),
    path('login/', login_user, name='login'),
    path('logout/', logout_user, name='logout'),  
    path("product/<str:id>/edit/", edit_product, name="edit_product"),
    path("product/<str:id>/delete/", delete_product, name="delete_product"),
    path("api/products/", views.api_products, name="api_products"),
    path("api/products/<uuid:pk>/", views.api_product_detail, name="api_product_detail"),
    path("api/auth/login/", views.api_login, name="api_login"),
    path("api/auth/register/", views.api_register, name="api_register"),
    path("api/auth/logout/", views.api_logout, name="api_logout"),
    path("api/auth/csrf/", views.api_csrf, name="api_csrf"),
    path("api/auth/session/", views.api_session, name="api_session"),
    path("api/sort/<str:type>", views.sort, name="sort")
]
