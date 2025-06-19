from django.urls import path
from .views import send_push_notification

urlpatterns = [
    path('send-notification/', send_push_notification),
]
