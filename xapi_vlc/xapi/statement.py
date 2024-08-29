from datetime import datetime

def create(event, player, userid):
    base_url = "https://yet.systems/xapi/profiles/vlc"
    verb_url = base_url+"/verbs"
    activity_url = base_url+"/activitytype"
    video_url = activity_url+"/video"

    # TODO: integrate playback time into the statements
    playback_time = player.get_time()
    playback_time_seconds = playback_time / 1000.0
    print(f"Event type: {event.type} occurred at {playback_time_seconds:.2f} seconds")

    media = player.get_media()

    # TODO: integrate metadata into statements: http://www.olivieraubert.net/vlc/python-ctypes/doc/vlc.Meta-class.html
    title = media.get_meta(vlc.Meta.Title)
    director = media.get_media(vlc.Meta.Director)
    url = media.get_media(vlc.Meta.URL)
    print(f"Title: {title}")
    print(f"Director: {director}")
    print(f"URL: {url}")
    
    return {
        "actor": {
            "mbox": f"mailto:{userid}"
        },
        "verb": { 
            "id": f"{verb_url}/{event.type}"
        },
        "object": {
            "id": f"{video_url}/{media.get_mrl()}"
            # "definition": {
            #     "name": {"en-US": media_title},
            #     "description": {"en-US": f"The media file being {verb['display']['en-US']}."}
            # }
        },
        "timestamp": datetime.utcnow().isoformat() + "Z"
    }
