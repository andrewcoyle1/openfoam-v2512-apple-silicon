#!/usr/bin/env bash
# Creates a case-sensitive APFS sparse image for the ESI OpenFOAM v2512 build.
# macOS's default filesystem is case-insensitive; OpenFOAM requires case-sensitivity.
#
# Usage: bash 01-create-volume.sh [options]
#
# Options:
#   --image PATH    Path for the sparse image  (default: ~/openfoam/ESI/openfoam-esi-cs.sparseimage)
#   --volume NAME   Volume name under /Volumes  (default: OpenFOAM-ESI)
#   --size GB       Sparse image size in gigabytes  (default: 15)

set -e

IMAGE_PATH="$HOME/openfoam/ESI/openfoam-esi-cs.sparseimage"
VOLUME_NAME="OpenFOAM-ESI"
SIZE_GB=15

while [[ $# -gt 0 ]]; do
    case "$1" in
        --image)  IMAGE_PATH="$2";  shift 2 ;;
        --volume) VOLUME_NAME="$2"; shift 2 ;;
        --size)   SIZE_GB="$2";     shift 2 ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

if [ -f "$IMAGE_PATH" ]; then
    echo "Sparse image already exists at $IMAGE_PATH"
    echo "To recreate it, delete the file first: rm \"$IMAGE_PATH\""
    exit 1
fi

mkdir -p "$(dirname "$IMAGE_PATH")"

echo "Creating ${SIZE_GB}GB case-sensitive APFS sparse image at $IMAGE_PATH..."
hdiutil create \
    -size "${SIZE_GB}g" \
    -fs "Case-sensitive APFS" \
    -type SPARSE \
    -volname "$VOLUME_NAME" \
    "$IMAGE_PATH"

echo "Mounting sparse image..."
hdiutil attach "$IMAGE_PATH" -quiet

echo ""
echo "Done. Volume is mounted at /Volumes/$VOLUME_NAME"
echo "Run scripts/02-clone.sh next."
