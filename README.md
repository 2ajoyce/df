# Dwarf Fortress Web

A containerized Dwarf Fortress environment with a built-in web-based VNC client for graphical gameplay in the browser.

This project allows you to run Dwarf Fortress in a Docker container and access its graphical interface through any modern web browser.

## First Time Setup

- Ensure you have Docker and [just](https://github.com/casey/just) installed.
- Build the Docker image: `just update`
  - **Warning:** This may update Dwarf Fortress to a newer version. Existing saves may become unusable if the game version changes.
- Start the server: `just up`
- Access the game at [http://localhost:7681/vnc.html](http://localhost:7681/vnc.html).

## Commands

Application

- Start: `just up`

- Stop: `just down`

- Open Browser: `just browser`

- Update DF: `just update` (possibly breaking)

  - Existing saves may become unusable if the game version changes.

Backups

- Create Backup `just backup`

- List Backups `just backups`

- Restore Backup `just restore save-20260111_215551.tar.gz`

SmokeTest

- Generate Pocket World `just smoke-test`

  - This will generate a pocket world and leave the UI on the main menu.
  - It does not select the game type or embark.

Development

- View Logs: `just logs`

  - Includes the `-f` flag by default.

- Open Container Shell: `just shell`

## License

MIT
