#!/usr/bin/env bash
# Installs the shell helper and LaunchAgent for auto-mounting the sparse image at login.
#
# Usage: bash 05-install-env.sh [options]
#
# Options:
#   --image PATH   Path to the sparse image  (default: ~/openfoam/ESI/openfoam-esi-cs.sparseimage)

set -e

IMAGE_PATH="$HOME/openfoam/ESI/openfoam-esi-cs.sparseimage"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --image) IMAGE_PATH="$2"; shift 2 ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_DIR="$SCRIPT_DIR/../env"

# Shell helper
cp "$ENV_DIR/of-esi-env.sh" "$HOME/of-esi-env.sh"
echo "Installed: ~/of-esi-env.sh"
echo "  Usage: source ~/of-esi-env.sh"

# LaunchAgent — substitute actual image path
PLIST_DST="$HOME/Library/LaunchAgents/com.openfoam-esi.mount.plist"
sed "s|/Users/andrewcoyle/openfoam/ESI/openfoam-esi-cs.sparseimage|$IMAGE_PATH|g" \
    "$ENV_DIR/com.openfoam-esi.mount.plist" > "$PLIST_DST"
launchctl load "$PLIST_DST"
echo "Installed: LaunchAgent (auto-mounts sparse image at login)"

echo ""
echo "Done. The OpenFOAM-ESI volume will mount automatically at every login."
echo "To load the environment in a new shell: source ~/of-esi-env.sh"
