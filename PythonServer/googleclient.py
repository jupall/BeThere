from __future__ import print_function

import datetime
import os.path
import iso8601
import json

from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError

# If modifying these scopes, delete the file token.json.
SCOPES = ['https://www.googleapis.com/auth/calendar.readonly']


def main():
    """Shows basic usage of the Google Calendar API.
    Prints the start and name of the next 10 events on the user's calendar.
    """
    creds = None
    # The file token.json stores the user's access and refresh tokens, and is
    # created automatically when the authorization flow completes for the first
    # time.
    if os.path.exists('token.json'):
        creds = Credentials.from_authorized_user_file('token.json', SCOPES)
    # If there are no (valid) credentials available, let the user log in.
    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            creds.refresh(Request())
        else:
            flow = InstalledAppFlow.from_client_secrets_file(
                'credentials.json', SCOPES)
            creds = flow.run_local_server(port=0)
        # Save the credentials for the next run
        with open('token.json', 'w') as token:
            token.write(creds.to_json())

    try:
        service = build('calendar', 'v3', credentials=creds)
        # Call the Calendar API and find the primary calendar
        list = service.calendarList().list().execute()
        print(json.dumps(list, indent=4))
        items = list["items"]
        primaryCalendarId = ""
        for item in items:
            if("primary" in item):
                primaryCalendarId = item["id"]
        if(primaryCalendarId == ""):
            print("No primary calendar found")
            return
        freeTime(primaryCalendarId, service) 

    except HttpError as error:
        print('An error occurred: %s' % error)

def freeTime(user: str, service):
    now = datetime.datetime.utcnow().isoformat() + 'Z'  # 'Z' indicates UTC time
    print("____ begin freebusy test ____")
    nextWeek = (datetime.datetime.utcnow() + datetime.timedelta(days=7)).isoformat()
    print(nextWeek)
    body = {
            "timeMin": now,
            "timeMax": nextWeek + 'Z',
            "timeZone": "US/Eastern",
            "items": [{"id": user}]
        }
    freebusy = service.freebusy().query(body = body).execute()

    # get the list of busy times
    busyTimes = freebusy['calendars'][user]['busy']
    now = datetime.datetime.now().replace(microsecond=0)
    # add night time as busy time
    if(21 < now.hour or now.hour < 8):
        # add time until eight o'clock tomorrow
        busyTimes.append({'start': now.isoformat(), 'end': (now + datetime.timedelta(days=1)).replace(hour=8, minute=0, second=0, microsecond=0).isoformat()})
    # add night time from 9pm to 8am every day
    for i in range(7):
        busyTimes.append({'start': (now + datetime.timedelta(days=i)).replace(hour=21, minute=0, second=0, microsecond=0).isoformat(), 'end': (now + datetime.timedelta(days=i+1)).replace(hour=8, minute=0, second=0, microsecond=0).isoformat()})

    # order the busy times by start time
    busyTimes.sort(key = lambda x: x['start'])
    
    for b in busyTimes:
        # check if the start time is before the end time of next element
        nextElement = busyTimes.index(b) + 1
        if(nextElement == len(busyTimes)):
            break
        while(iso8601.parse_date(b['end']) >= iso8601.parse_date(busyTimes[nextElement]['start'])):
            # if the end time of the current element is after the start time of the next element
            # then then the end time of the current element is the end time of the next element
            b['end'] = busyTimes[nextElement]['end']
            busyTimes.remove(busyTimes[nextElement])
            if(nextElement == len(busyTimes)):
                break
        # we end up with a list of busy times that don't overlap
    
    # iterate through the list of busy times and add the free time between each element
    freeTime = []
    for b in busyTimes:
        if (iso8601.parse_date(b['start']) - iso8601.parse_date(now.isoformat())).total_seconds() > 0 and busyTimes.index(b) == 0:
            freeTime.append({'start': now.isoformat(), 'end': b['start']})
        nextElement = busyTimes.index(b) + 1
        if(nextElement == len(busyTimes)):
            nextWeekTrunc = nextWeek[:-7]
            freeTime.append({'start': b['end'], 'end': nextWeekTrunc})
        else: freeTime.append({'start': b['end'], 'end': busyTimes[nextElement]['start']})
    
    print(json.dumps(freeTime, indent=4))    
    
    return freeTime

if __name__ == '__main__':
    main()