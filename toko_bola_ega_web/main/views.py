
import datetime
from django.utils.timezone import localtime, now
import json


from django.contrib import messages
from django.contrib.auth import authenticate, login, logout
from django.contrib.auth.decorators import login_required
from django.contrib.auth.forms import AuthenticationForm, UserCreationForm
from django.core import serializers
from django.db.models import Q
from django.forms import ModelForm
from django.http import (
    HttpResponse,
    HttpResponseBadRequest,
    HttpResponseForbidden,
    HttpResponseRedirect,
    JsonResponse,
)
from django.shortcuts import get_object_or_404, redirect, render
from django.urls import reverse
from django.middleware.csrf import get_token
from django.views.decorators.csrf import ensure_csrf_cookie
from django.views.decorators.http import require_http_methods

from main.forms.forms import ProductForm
from .models import Product





@login_required(login_url='/login')
def show_main(request):
    filter_type   = request.GET.get("filter", "all")
    category_code = request.GET.get("category", "all")

    qs = Product.objects.select_related("user")

    if filter_type == "my":
        qs = qs.filter(user=request.user)

    if category_code != "all":
        code_to_label = dict(Product.categories())
        codes   = list(code_to_label.keys())
        labels  = list(code_to_label.values())
        label   = code_to_label.get(category_code)

        query = Q(category=category_code)
        if label:
            query |= Q(category__iexact=label) 
        if category_code == "misc":
            query |= (~Q(category__in=codes + labels)
                      & ~Q(category__isnull=True)
                      & ~Q(category=""))

        qs = qs.filter(query)

    products = qs.order_by("-created_at")

    student = {
        "title": "Football News",
        "npm": "2406434153",
        "name": "Gregorius Ega Aditama Sudjali",
        "kelas": "PBP C",
        "username": request.user.username,
        "last_login": request.COOKIES.get("last_login", "Never"),
    }

    context = {
        "products": products,
        "student": student,
        "last_login": student["last_login"],
        "current_filter": filter_type,
        "current_category": category_code,
        "categories": Product.categories(),
        "is_all_active": filter_type != "my",
        "is_my_active":  filter_type == "my",
    }
    return render(request, "main/main.html", context)


@login_required(login_url='/login')
def create_product(request):
    form = ProductForm(request.POST or None)
    if form.is_valid() and request.method == "POST":
        product = form.save(commit=False)
        product.user = request.user

        category_code = form.cleaned_data.get("category")
        custom = form.cleaned_data.get("category_custom", "").strip()
        if category_code == "misc" and custom:
            product.category = custom 

        product.save()
        return redirect("main:show_main")
    return render(request, "main/create_product.html", {"form": form, "categories": Product.categories()})


@login_required(login_url='/login')
def show_product(request, id):
    product = get_object_or_404(Product, pk=id)
    product.increment_views()
    return render(request, "main/product_detail.html", {"product": product})


def show_xml(request):
    data = Product.objects.all()
    xml_data = serializers.serialize("xml", data)
    return HttpResponse(xml_data, content_type="application/xml")


def show_json(request):
    data = Product.objects.all()
    json_data = serializers.serialize("json", data)
    return HttpResponse(json_data, content_type="application/json")



def show_xml_by_id(request, id):
    data = Product.objects.filter(pk=id)
    if not data.exists():
        return HttpResponse(status=404)
    xml_data = serializers.serialize("xml", data)
    return HttpResponse(xml_data, content_type="application/xml")


def show_json_by_id(request, id):
    try:
        obj = Product.objects.get(pk=id)
    except Product.DoesNotExist:
        return HttpResponse(status=404)
    json_data = serializers.serialize("json", [obj]) 
    return HttpResponse(json_data, content_type="application/json")


def register(request):
    form = UserCreationForm()

    if request.method == "POST":
        form = UserCreationForm(request.POST)
        if form.is_valid():
            form.save()
            messages.success(request, 'Your account has been successfully created!')
            return redirect('main:login')
    context = {'form':form}
    return render(request, 'main/register.html', context)


def login_user(request):
   if request.method == 'POST':
      form = AuthenticationForm(data=request.POST)

      if form.is_valid():
        user = form.get_user()
        login(request, user)
        response = HttpResponseRedirect(reverse("main:show_main"))
        response.set_cookie('last_login', str(datetime.datetime.now()))
        return response

   else:
      form = AuthenticationForm(request)
   context = {'form': form}
   return render(request, 'main/login.html', context)

def logout_user(request):
    logout(request)
    response = HttpResponseRedirect(reverse('main:login'))
    response.delete_cookie('last_login')
    return response


@login_required(login_url='/login')
def edit_product(request, id):
    product = get_object_or_404(Product, pk=id)
    if product.user != request.user:
        return HttpResponseForbidden("You cannot edit this product.")

    form = ProductForm(request.POST or None, instance=product)
    if request.method == "POST" and form.is_valid():
        form.save()
        messages.success(request, "Product updated.")
        return redirect("main:show_product", id=str(product.pk))

    return render(request, "main/edit_product.html", {"form": form, "product": product})

def sort(request, type):
    data = None
    if type == "asc":
        data = Product.objects.order_by("price")
    else:
        data = Product.objects.order_by("price").reverse()
    json_data = serializers.serialize("json", data)
    return HttpResponse(json_data, content_type="application/json")
    



@login_required(login_url='/login')
def delete_product(request, id):
    product = get_object_or_404(Product, pk=id)
    if product.user != request.user:
        return HttpResponseForbidden("You cannot delete this product.")

    if request.method == "POST":
        product.delete()
        messages.success(request, "Product deleted.")
        return redirect("main:show_main")

    return render(request, "main/confirm_delete.html", {"product": product})


class ProductAPIForm(ModelForm):
    class Meta:
        model = Product
        fields = ["category", "name", "brand", "price", "thumbnails", "description", "is_featured"]

def _to_dict(obj, request):
    return obj.as_dict(request_user=request.user)
 
@require_http_methods(["GET", "POST"])
def api_products(request):
    if request.method == "GET":
        qs = Product.objects.select_related("user").order_by("-created_at")
        if request.GET.get("mine") == "1" and request.user.is_authenticated:
            qs = qs.filter(user=request.user)
        q = request.GET.get("q")
        if q:
            from django.db.models import Q
            qs = qs.filter(Q(name__icontains=q) | Q(brand__icontains=q) | Q(description__icontains=q))
        return JsonResponse({"ok": True, "count": qs.count(), "items": [_to_dict(p, request) for p in qs]})

    if not request.user.is_authenticated:
        return JsonResponse({"ok": False, "errors": {"auth": ["Login required"]}}, status=401)
    try:
        payload = json.loads(request.body.decode("utf-8"))
    except Exception:
        return HttpResponseBadRequest("Invalid JSON")
    form = ProductAPIForm(payload)
    if form.is_valid():
        product = form.save(commit=False)
        product.user = request.user
        product.save()
        return JsonResponse({"ok": True, "item": _to_dict(product, request)}, status=201)
    return JsonResponse({"ok": False, "errors": form.errors}, status=400)

@require_http_methods(["GET", "PATCH", "DELETE"])
def api_product_detail(request, pk):
    product = get_object_or_404(Product, pk=pk)   # always bound

    if request.method == "GET":
        if request.GET.get("track") == "1":
            product.increment_views()
        return JsonResponse({"ok": True, "item": product.as_dict(request_user=request.user)})

    # Mutations: auth + ownership
    if not request.user.is_authenticated:
        return JsonResponse({"ok": False, "errors": {"auth": ["Login required"]}}, status=401)
    if product.user_id != request.user.id:
        return JsonResponse({"ok": False, "errors": {"perm": ["Not your product"]}}, status=403)

    if request.method == "PATCH":
        # strict JSON parse (return 400 "Invalid JSON" on bad body)
        try:
            payload = json.loads(request.body.decode("utf-8"))
        except Exception:
            return HttpResponseBadRequest("Invalid JSON")

        # normalize/coerce incoming types
        if "is_featured" in payload:
            v = payload["is_featured"]
            payload["is_featured"] = True if v in (True, "true", "True", 1, "1", "on") else False
        if "price" in payload and payload["price"] not in (None, ""):
            try:
                payload["price"] = int(payload["price"])
            except Exception:
                return JsonResponse({"ok": False, "errors": {"price": ["Must be an integer"]}}, status=400)

        # emulate partial update by merging with current instance
        fields = ["category", "name", "brand", "price", "thumbnails", "description", "is_featured"]
        data_full = {f: getattr(product, f) for f in fields}
        data_full.update({k: v for k, v in payload.items() if k in fields})

        form = ProductAPIForm(data_full, instance=product)   # no partial=True (Django form)
        if form.is_valid():
            updated = form.save()  # <-- DO NOT reassign "product"
            return JsonResponse({"ok": True, "item": updated.as_dict(request_user=request.user)})
        return JsonResponse({"ok": False, "errors": form.errors}, status=400)

    # DELETE
    product.delete()
    return JsonResponse({"ok": True})


def _user_payload(user):
    if user is None:
        return None
    return {
        "username": user.username,
        "name": user.get_full_name() or user.username,
        "email": user.email,
    }


@require_http_methods(["POST"])
def api_login(request):
    content_type = (request.META.get("CONTENT_TYPE") or "").lower()
    payload = {}

    if "json" in content_type:
        try:
            payload = json.loads(request.body.decode("utf-8"))
        except Exception:
            return HttpResponseBadRequest("Invalid JSON")
    elif request.POST:
        payload = request.POST
    else:
        # Some clients (e.g. pbp_django_auth CookieRequest.login) submit form
        # data without an explicit content-type. Try JSON as a fallback, and
        # finally leave payload empty (handled below).
        try:
            payload = json.loads(request.body.decode("utf-8"))
        except Exception:
            payload = {}

    username = payload.get("username", "")
    password = payload.get("password", "")
    if not username or not password:
        return JsonResponse({"ok": False, "errors": {"__all__": ["Username dan password wajib diisi."]}}, status=400)

    user = authenticate(request, username=username, password=password)
    if user is None:
        return JsonResponse({"ok": False, "errors": {"__all__": ["Invalid credentials"]}}, status=400)

    login(request, user)
    last_login = localtime(now()).strftime("%d %b %Y %H:%M")
    resp = JsonResponse({"ok": True, "user": _user_payload(user), "last_login": last_login})
    resp.set_cookie("last_login", last_login, samesite="Lax")
    return resp


@require_http_methods(["POST"])
def api_logout(request):
    from django.contrib.auth import logout
    logout(request)
    resp = JsonResponse({"ok": True})
    resp.delete_cookie("last_login")
    return resp


@require_http_methods(["POST"])
def api_register(request):
    from django.contrib.auth.forms import UserCreationForm
    try:
        payload = json.loads(request.body.decode("utf-8"))
    except Exception:
        return HttpResponseBadRequest("Invalid JSON")
    form = UserCreationForm(payload)
    if form.is_valid():
        user = form.save()
        login(request, user)
        last_login = localtime(now()).strftime("%d %b %Y %H:%M")
        resp = JsonResponse({"ok": True, "user": _user_payload(user), "last_login": last_login})
        resp.set_cookie("last_login", last_login, samesite="Lax")
        return resp
    return JsonResponse({"ok": False, "errors": form.errors}, status=400)


@ensure_csrf_cookie
@require_http_methods(["GET"])
def api_csrf(request):
    token = get_token(request)
    return JsonResponse({"ok": True, "csrfToken": token})


@require_http_methods(["GET"])
def api_session(request):
    if request.user.is_authenticated:
        return JsonResponse({"ok": True, "user": _user_payload(request.user)})
    return JsonResponse({"ok": False}, status=401)
