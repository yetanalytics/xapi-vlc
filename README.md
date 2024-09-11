# XAPI VLC

An XAPI integrated VLC player

### Setup

1) Run `make install` . This will move the plugin into the appropriate directory for VLC.
2) Open VLC. when you do, click on the view dropdown and click 'xAPI Integration.'
3) Enter the fields in the form:

- Homepage URL: Domain specific URL to identify from which system the user is located
- API Key: Key for LRS
- API Secret: Secret for LRS
- API URL: URL for lrs (example: http://localhost:8080/xapi/statements)

4) Play a video of your choice and verify the data is flowing from the LRS.

### Dev

All code is located at `xapi.lua`. In VLC you can go to the console log (via ctrl+M) to see what the code is doing. If you wish to update the plugin, just save your changes to `xapi.lua` and run `make install` again.
