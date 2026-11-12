# PlayGTA5 Mobile iOS wrapper

This is a lightweight iOS WebView shell with landscape orientation and touch controls. It does not contain the GTA V engine or Rockstar game data.

## Important
The repository README says the game data is a separate local .mirror folder. The IPA cannot load files from a PC automatically. Run the authorized browser game host on a computer on the same Wi-Fi as the iPhone, then enter its LAN address in the app (for example http://192.168.1.20:8000). Keep the host running while playing.

The default address is a placeholder and must be changed to your computer's actual LAN IP. The touch overlay provides WASD, jump, run, interaction, fire and swipe-to-look controls; exact compatibility depends on the browser port's input handling.

## Build
Run the Build PlayGTA5 Mobile IPA workflow from GitHub Actions. The artifact is unsigned; installation requires signing with your own Apple developer signing method or a compatible sideloading tool.
