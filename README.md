# XAPI VLC

XAPI integration with VLC player

### Dev Setup

#### VLC Player

Install vlc and libvlc via your package manager of choice.

#### VENV and Dependencies

1) Install virtualenv via `pip install virtualenv` or if you're on mac and use Brew you can install it via `brew install virtualenv`.
2) start a virtual env via `python -m venv env`
3) Make sure your environment has the venv available using the following command: `source env/bin/activate`
4) Now you can install the application dependencies by running `pip install -r requirements.txt`

The dependencies will be made available in the `env` directory.

#### Running the Player.

1) put a movie file somewhere. For the purposes of demonstration, I'm putting a movie file in `.resources/movie.mkv`
2) You can run the player with the command `python -m xapi_vlc.main .resources/movie.mkv`. Happy Hunting!
