# Justfile for Dwarf Fortress Hybrid Web Project (Graphical)

LATEST_URL := "https://www.bay12games.com/dwarves/" + `curl -s https://www.bay12games.com/dwarves/index.html | grep -oE "df_[0-9_]+_linux\.tar\.bz2" | head -n 1`

# Build or update the Docker image. Specify URL with `just update URL="..."`
update URL=LATEST_URL:
    docker compose build --build-arg DF_URL={{URL}}

# Start the Dwarf Fortress server
up:
    docker compose up -d
    @echo "Dwarf Fortress (Graphical) is starting at http://localhost:7681/vnc.html"

# Stop the server
down:
    docker compose down

# Open the browser UI
browser:
    powershell -Command "Start-Process 'http://localhost:7681/vnc.html'"

# View logs. Use `just logs FLAGS="..."` to override default `-f`
logs FLAGS="-f":
    docker compose logs {{FLAGS}}

# Access the container shell
shell:
    docker compose exec dwarf-fortress bash

# Backup saves to local project folder with a timestamp. Use `just backup FLAGS="-T"` in CI.
backup FLAGS="":
    mkdir -p backups
    docker compose exec {{FLAGS}} dwarf-fortress sh -c "tar -czf /opt/df/backups/save-\$(date +%Y%m%d_%H%M%S).tar.gz -C /opt/df/data save"
    @echo "Backup created in backups/ folder."

# List all available backups
backups:
    @ls -lh backups/

# Restore a backup from the backups folder. Usage: just restore FILE="save-20260111_120000.tar.gz" [FLAGS="-T"]
restore FILE FLAGS="":
    @echo "Targeting backup: backups/{{FILE}}"
    @echo "WARNING: This will overwrite your current save! (Ctrl+C to abort)"
    @sleep 3
    @echo "Stopping server..."
    docker compose stop dwarf-fortress
    @echo "Restoring..."
    docker compose run {{FLAGS}} --rm dwarf-fortress sh -c "rm -rf /opt/df/data/save/* && tar -xzf /opt/df/backups/{{FILE}} -C /opt/df/data"
    @echo "Restarting server..."
    docker compose start dwarf-fortress
    @echo "Restore complete! Refresh your browser."
