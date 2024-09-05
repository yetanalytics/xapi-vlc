import sys
import subprocess
import time
import pexpect
import threading
import atexit
import re

# function that strips the data of the command and only returns response.
def parse_response(output):
    match = re.search(r'^\w+\r?\n([\s\S]*)', output)
    if match:
        return match.group(1)
    return None

class VLCController:
    def __init__(self, filepath=None):
        self.vlc_process = pexpect.spawn(f"vlc --extraintf rc {filepath}")
        self.previous_state = None
        time.sleep(2)  # Allow time for VLC to start
        self.running = False
        self.event_thread = None
        
        # calls stop event watcher when exit occurs
        atexit.register(self.stop_event_watcher)

    ## communications and parsing RC
    def flush_output(self):
        """Flush any leftover output from the previous command."""
        while self.vlc_process.expect(['>', pexpect.TIMEOUT], timeout=0.1) == 0:
            self.vlc_process.before

    def send_command(self, command):
        self.flush_output()
        self.vlc_process.sendline(command)
        self.vlc_process.expect('>')
        return parse_response(self.vlc_process.before.decode('utf-8').strip())

    def get_time(self):
        response = self.send_command("get_time")
        try:
            return int(response)
        except TypeError:
            return 0

    def get_title(self):
        response = self.send_command("get_title")
        return response

    def get_status(self):
        return self.send_command("status")

    def get_length(self):
        response = self.send_command("get_length")
        try:
            return int(response)
        except TypeError:
            return 0

    def form_metadata_map(self, status):
        return {"status": status,
                "title": self.get_title(),
                "time": self.get_time(),
                "length": self.get_length()}

    def play(self):
        self.send_command("play")


    ## Event Watching
    def parse_status(self, status_output, callback):
        if "state playing" in status_output and self.previous_state != "playing":
            callback(self.form_metadata_map("playing"))
            self.previous_state = "playing"
        elif "state paused" in status_output and self.previous_state != "paused":
            callback(self.form_metadata_map("paused"))
            self.previous_state = "paused"
        elif "state stopped" in status_output and self.previous_state != "stopped":
            callback(self.form_metadata_map("stopped"))
            self.previous_state = "stopped"
        elif "state ended" in status_output and self.previous_state != "ended":
            callback(self.form_metadata_map("finished"))
            self.previous_state = "ended"

    def on_state_change(self, callback):
        while self.running:
            status = self.get_status()
            self.parse_status(status, callback)

    def start_event_watcher(self, callback):
        if not self.running:
            self.running = True
            self.event_thread = threading.Thread(target=self.on_state_change, args=(callback,))
            self.event_thread.start()

    def stop_event_watcher(self):
        self.running = False
        if self.event_thread:
            self.event_thread.join()
