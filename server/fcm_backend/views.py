from django.shortcuts import render
import json
import requests
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from google.oauth2 import service_account
from google.auth.transport.requests import Request

FCM_SCOPE = ['https://www.googleapis.com/auth/firebase.messaging']
SERVICE_ACCOUNT_FILE = 'serviceAccountKey.json' 

@csrf_exempt
def send_push_notification(request):
    if request.method != 'POST':
        return JsonResponse({'error': 'Only POST allowed'}, status=405)

    try:
        body = json.loads(request.body)
        fcm_token = body.get('token')

        if not fcm_token:
            return JsonResponse({'error': 'Missing FCM token'}, status=400)

        credentials = service_account.Credentials.from_service_account_file(
            SERVICE_ACCOUNT_FILE, scopes=FCM_SCOPE)
        request_obj = Request()
        credentials.refresh(request_obj)

        access_token = credentials.token
        project_id = credentials.project_id

        url = f"https://fcm.googleapis.com/v1/projects/{project_id}/messages:send"
        headers = {
            'Authorization': f'Bearer {access_token}',
            'Content-Type': 'application/json; UTF-8',
        }

        message_payload = {
            "message": {
                "token": fcm_token,
                "notification": {
                    "title": "Django FCM",
                    "body": "Hello from Django FCM v1 backend"
                }
            }
        }

        response = requests.post(url, headers=headers, data=json.dumps(message_payload))

        return JsonResponse({
            'status': response.status_code,
            'response': response.json()
        })

    except Exception as e:
        return JsonResponse({'error': str(e)}, status=500)

