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
    @echo "10 seconds to abort..."
    @sleep 1
    @for i in 9 8 7 6 5 4 3 2 1; do echo "$i..."; sleep 1; done
    @echo "Restoring"
    @echo "Stopping server..."
    docker compose stop dwarf-fortress
    @echo "Restoring..."
    docker compose run {{FLAGS}} --rm dwarf-fortress sh -c "rm -rf /opt/df/data/save/* && tar -xzf /opt/df/backups/{{FILE}} -C /opt/df/data"
    @echo "Restarting server..."
    docker compose start dwarf-fortress
    @echo "Restore complete! Refresh your browser."

# Run a smoke test to initialize world. Use while the browser is open to watch!
smoke-test:
    @echo "Activating Dwarf Fortress window and clicking 'Create New World'..."
    docker compose exec -e DISPLAY=:1 dwarf-fortress xdotool search --name "Dwarf Fortress" windowactivate --sync
    
    @echo "Clicking 'Create New World' button..."
    docker compose exec -e DISPLAY=:1 dwarf-fortress xdotool mousemove 640 440 mousedown 1 sleep 0.2 mouseup 1
    @sleep 3
    
    @echo "Clicking 'Okay' on the welcome prompt..."
    docker compose exec -e DISPLAY=:1 dwarf-fortress xdotool mousemove 640 300 mousedown 1 sleep 0.2 mouseup 1
    @sleep 3
    
    @echo "Selecting 'Pocket' world size..."
    docker compose exec -e DISPLAY=:1 dwarf-fortress xdotool mousemove 100 80 mousedown 1 sleep 0.2 mouseup 1
    @sleep 1
    
    @echo "Confirming world generation..."
    docker compose exec -e DISPLAY=:1 dwarf-fortress xdotool mousemove 800 750 mousedown 1 sleep 0.2 mouseup 1
    @sleep 1
    @echo "Check your browser! World generation should be starting."

    @echo "Waiting 30 seconds for world generation to proceed..."
    @sleep 10

    @echo "Returning to main menu..."
    docker compose exec -e DISPLAY=:1 dwarf-fortress xdotool mousemove 300 275 mousedown 1 sleep 0.2 mouseup 1
    @sleep 3