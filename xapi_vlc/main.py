import sys
import vlc
from PySide6.QtWidgets import QApplication, QMainWindow
from PySide6.QtCore import Qt


# Define a logging function that takes the player as an argument
def make_logger(player):
    def print_media_metadata(player):
        # Get the associated media object
        media = player.get_media()
        
        if not media:
            print("No media loaded")
            return
        
        # Ensure metadata is parsed
        media.parse()  # Can use media.parse_with_options(vlc.MediaParseFlag.network) if needed
        
        # Get the filename (Media Resource Locator, MRL)
        mrl = media.get_mrl()
        print(f"Filename (MRL): {mrl}")
        
        # Extracting other metadata
        title = media.get_meta(vlc.Meta.Title)
        artist = media.get_meta(vlc.Meta.Artist)
        album = media.get_meta(vlc.Meta.Album)
        genre = media.get_meta(vlc.Meta.Genre)
        track_number = media.get_meta(vlc.Meta.TrackNumber)
        
        # Print out the metadata
        print(f"Title: {title}")
        print(f"Artist: {artist}")
        print(f"Album: {album}")
        print(f"Genre: {genre}")
        print(f"Track Number: {track_number}")

    def log(event):
        # Get the current playback time in milliseconds
        playback_time = player.get_time()
        
        # Convert to seconds for easier reading (optional)
        playback_time_seconds = playback_time / 1000.0
        
        # Log the event time
        print(f"Event type: {event.type} occurred at {playback_time_seconds:.2f} seconds")

        print_media_metadata(player)
    return log

class VLCWindow(QMainWindow):
    def __init__(self, filepath):
        super().__init__()

        # Set up VLC player
        self.instance = vlc.Instance()
        self.player = self.instance.media_player_new()
        media = self.instance.media_new(filepath)
        self.player.set_media(media)
        self.player.set_nsobject(self.winId())

        # Attach Events
        logger = make_logger(self.player)
        event_manager = self.player.event_manager()
        event_manager.event_attach(vlc.EventType.MediaPlayerPlaying, logger)
        event_manager.event_attach(vlc.EventType.MediaPlayerEndReached, logger)
        event_manager.event_attach(vlc.EventType.MediaPlayerPaused, logger)

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
    filepath = sys.argv[-1]
    app = QApplication(sys.argv)
    window = VLCWindow(filepath)
    window.show()
    sys.exit(app.exec())

if __name__ == "__main__":
    main()
