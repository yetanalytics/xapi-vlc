from datetime import datetime

def create(event, userid):
    base_url = "https://yet.systems/xapi/profiles/vlc"
    verb_url = base_url+"/verbs"
    activity_url = base_url+"/activitytype"
    video_url = activity_url+"/video"

    # TODO: integrate playback time into the statements
    time = event['time']
    length = event['length']
    
    return {
        "actor": {
            "mbox": f"mailto:{userid}"
        },
        "verb": { 
            "id": f"{verb_url}/{event['status']}"
        },
        "object": {
            "id": f"{video_url}/{event['title']}"
            # "definition": {
            #     "name": {"en-US": media_title},
            #     "description": {"en-US": f"The media file being {verb['display']['en-US']}."}
            # }
        },
        "timestamp": datetime.utcnow().isoformat() + "Z"
    }
