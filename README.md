# XAPI VLC

An XAPI integrated VLC player

### Setup

0) (optional) `make configure` will setup the configuration files for the plugin. to override defaults, run the command with the appropriate overrides. Example being: `make configure THRESHOLD=0.87`. The following is a list of variables and what they mean.
  - `THRESHOLD` - Decimal value between 0 and 1 that represents point in video considered a completion. Once a video reaches this threshold, the plugin will issue a completion statement
  - `API_KEY` - API key for LRS
  - `API_SECRET` - API Secret for LRS
  - `API_URL` - API Url for LRS
  - `API_HOMEPAGE` - system that identifies user. In the statement this is set at `actor.account.homePage`.

1) Run `make install` . This will move the plugin into the appropriate directory for VLC.
2) Open VLC. when you do, click on the view dropdown and click 'xAPI Integration.'
3) Enter the fields in the form:

- Homepage URL: Domain specific URL to identify from which system the user is located
- API Key: Key for LRS
- API Secret: Secret for LRS
- API Endpoint: Endpoint for LRS (example: https://localhost:8080/xapi)

4) Play a video of your choice and verify the data is flowing from the LRS.

### Dev

All code is located at `xapi.lua`. In VLC you can go to the console log (via ctrl+M) to see what the code is doing. If you wish to update the plugin, just save your changes to `xapi.lua` and run `make install` again.

### License

Copyright © 2024 Yet Analytics, Inc.

This module is licensed under the GNU Lesser General Public License 2.1 or later.
