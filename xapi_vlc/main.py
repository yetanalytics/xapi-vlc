import sys
import vlc
import argparse
from xapi_vlc.xapi import client
from xapi_vlc.xapi import statement
from PySide6.QtWidgets import QApplication, QMainWindow
from PySide6.QtCore import Qt


def make_client(player, userid):
    
    def client_fn(event):
        data = statement.create(event, player, userid) 
        client.send(data)

    return client_fn

class VLCWindow(QMainWindow):
    def __init__(self, filepath=None, userid=None):
        super().__init__()

        # Set up VLC player
        self.instance = vlc.Instance()
        self.player = self.instance.media_player_new()
        media = self.instance.media_new(filepath)
        self.player.set_media(media)
        self.player.set_nsobject(self.winId())

        # Attach Events
        # logger = make_logger(self.player)
        client = make_client(self.player, userid)
        event_manager = self.player.event_manager()
        event_manager.event_attach(vlc.EventType.MediaPlayerPlaying, client)
        event_manager.event_attach(vlc.EventType.MediaPlayerEndReached, client)
        event_manager.event_attach(vlc.EventType.MediaPlayerPaused, client)

        # Start playing the media
        self.player.play()

        # Set the window title and size
        self.setWindowTitle("VLC Player")
        self.setGeometry(100, 100, 800, 600)

    def keyPressEvent(self, event):
        """Handle key press events."""
        if event.key() == Qt.Key_Space:
            self.toggle_play_pause()

    def toggle_play_pause(self):
        """Toggle play/pause of the VLC player."""
        if self.player.is_playing():
            self.player.pause()
        else:
            self.player.play()

    def closeEvent(self, event):
        """Handle window close event."""
        self.player.stop()
        event.accept()

def main():
    parser = argparse.ArgumentParser(description="VLC Player that sends statements to an LRS.")
    parser.add_argument('--content', type=str, required=True, help="Path to content to be played.")
    parser.add_argument('--userid', type=str, required=True, help="User ID. (aka email)")

    args = parser.parse_args()


    app = QApplication(sys.argv)
    window = VLCWindow(filepath=args.content, userid=args.userid)
    window.show()
    sys.exit(app.exec())

if __name__ == "__main__":
    main()
