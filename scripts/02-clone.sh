#!/usr/bin/env bash
# Clones ESI OpenFOAM v2512 source into the case-sensitive volume.
# Requires a registered account at develop.openfoam.com.
#
# Usage: bash 02-clone.sh [options]
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

if [ ! -d "$VOLUME" ]; then
    echo "Error: $VOLUME is not mounted."
    echo "Run scripts/01-create-volume.sh first, or mount the existing image:"
    echo "  hdiutil attach ~/openfoam/ESI/openfoam-esi-cs.sparseimage"
    exit 1
fi

if [ -d "$VOLUME/OpenFOAM-v2512" ]; then
    echo "OpenFOAM-v2512 already exists at $VOLUME/OpenFOAM-v2512 — skipping clone."
else
    echo "Cloning ESI OpenFOAM v2512..."
    echo "Note: requires a develop.openfoam.com account."
    git clone https://develop.openfoam.com/Development/openfoam.git \
        --branch OpenFOAM-v2512 \
        --single-branch \
        "$VOLUME/OpenFOAM-v2512"
fi

echo ""
echo "Done. Run scripts/03-apply-patches.sh next."
