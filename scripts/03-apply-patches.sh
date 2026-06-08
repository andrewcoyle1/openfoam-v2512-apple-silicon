#!/usr/bin/env bash
# Applies macOS/Apple Silicon patches to the ESI OpenFOAM v2512 source tree.
#
# Usage: bash 03-apply-patches.sh [options]
#
# Options:
#   --volume NAME   Volume name under /Volumes  (default: OpenFOAM-ESI)

set -e

VOLUME_NAME="OpenFOAM-ESI"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --volume) VOLUME_NAME="$2"; shift 2 ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

VOLUME="/Volumes/$VOLUME_NAME"
OF_DIR="$VOLUME/OpenFOAM-v2512"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PATCHES_DIR="$SCRIPT_DIR/../patches"

if [ ! -d "$OF_DIR" ]; then
    echo "Error: $OF_DIR not found. Run scripts/02-clone.sh first."
    exit 1
fi

echo "Applying macOS/Apple Silicon patches to $OF_DIR..."
git -C "$OF_DIR" apply "$PATCHES_DIR/0001-openfoam-v2512-macos-apple-silicon.patch"

echo ""
echo "Done. Run scripts/04-build.sh next."
