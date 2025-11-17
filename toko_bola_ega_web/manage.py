
"""Django's command-line utility for administrative tasks."""
import os
import sys


def main() -> None:
    try:
        from dotenv import load_dotenv 
    except Exception:
        load_dotenv = None
    if load_dotenv:
        load_dotenv()

    settings_module = os.environ.get("DJANGO_SETTINGS_MODULE", "toko_bola_ega.settings")
    os.environ.setdefault("DJANGO_SETTINGS_MODULE", settings_module)

    if getattr(sys, "base_prefix", sys.prefix) == sys.prefix:
        print("⚠️  Not running inside a virtualenv. "
              "Activate it or create one to isolate dependencies.", file=sys.stderr)

    try:
        from django.core.management import execute_from_command_line
    except ModuleNotFoundError as exc:
        raise SystemExit(
            "Django is not installed in this environment.\n"
            "➡ Activate your venv and run: pip install -r requirements.txt"
        ) from exc

    execute_from_command_line(sys.argv)


if __name__ == "__main__":
    if sys.version_info < (3, 10):
        raise SystemExit("Python 3.10+ is required for this project.")
    main()
