import sys
import argparse
from xapi_vlc.vlc.api import VLCController
from xapi_vlc.xapi import client
from xapi_vlc.xapi import statement

def make_client(userid):
    def client_fn(event):
        data = statement.create(event, userid) 
        client.send(data)
    return client_fn

def main():
    parser = argparse.ArgumentParser(description="VLC Player that sends statements to an LRS.")
    parser.add_argument('--content', type=str, required=True, help="Path to content to be played.")
    parser.add_argument('--userid', type=str, required=True, help="User ID. (aka email)")

    args = parser.parse_args()

    client = make_client(args.userid)
    controller = VLCController(filepath=args.content)
    controller.play()
    print("Starting Event Watcher...")
    controller.start_event_watcher(client)

if __name__ == "__main__":
    main()
