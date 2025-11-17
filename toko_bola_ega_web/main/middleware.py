from urllib.parse import urlsplit

from django.conf import settings
from django.middleware.csrf import CsrfViewMiddleware


class DevCsrfViewMiddleware(CsrfViewMiddleware):
    """Allow localhost origins on arbitrary ports while developing."""

    def _origin_verified(self, request):
        if super()._origin_verified(request):
            return True

        if not getattr(settings, "DEBUG", False):
            return False

        allowed_hosts = getattr(settings, "DEV_HOSTS_ALLOW_ANY_PORT", ())
        if not allowed_hosts:
            return False

        origin = request.META.get("HTTP_ORIGIN")
        if not origin:
            return False

        try:
            parsed = urlsplit(origin)
        except ValueError:
            return False

        hostname = (parsed.hostname or "").lower()
        return hostname in allowed_hosts
