web: python manage.py migrate && python manage.py collectstatic --noinput && gunicorn --bind 0.0.0.0:$PORT --workers 4 --timeout 120 exhibition_project.wsgi:application

