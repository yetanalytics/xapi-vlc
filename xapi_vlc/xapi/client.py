import requests
from requests.auth import HTTPBasicAuth
import os

def send(data):
    # get creds go here
    lrs_key = os.environ.get('VLC_LRS_KEY')
    lrs_secret = os.environ.get('VLC_LRS_SECRET')
    url = os.environ.get('VLC_LRS_ENDPOINT')

    headers = {
            "Content-Type": "application/json",
            "X-Experience-API-Version": "1.0.3"
            }

    response = requests.post(url+"/xapi/statements", json=data, headers=headers, auth=HTTPBasicAuth(lrs_key, lrs_secret))

    if response.ok:
        print("statement sent successfully:", response.text)
    else:
        print("Failed to send statement:", response.status_code)
