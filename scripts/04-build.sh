#!/usr/bin/env bash
# Builds ESI OpenFOAM v2512 natively on macOS Apple Silicon.
# Requires: Xcode CLT, Homebrew dependencies (see README).
#
# Usage: bash 04-build.sh [options]
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

if [ ! -d "$OF_DIR" ]; then
    echo "Error: $OF_DIR not found. Run scripts/02-clone.sh and 03-apply-patches.sh first."
    exit 1
fi

echo "Loading ESI OpenFOAM v2512 environment..."
set +e
source "$SCRIPT_DIR/../env/of-esi-env.sh"
set -e

CORES=$(sysctl -n hw.perflevel0.physicalcpu 2>/dev/null || sysctl -n hw.physicalcpu)
echo "Building ESI OpenFOAM v2512 with $CORES cores..."
echo "This takes 60–90 minutes on an M4 Mac mini."
echo ""

cd "$OF_DIR"
./Allwmake -j"$CORES" 2>&1 | tee "$VOLUME/build.log"

if [ "${PIPESTATUS[0]}" -ne 0 ]; then
    echo "Build failed — see $VOLUME/build.log" >&2
    exit 1
fi

echo ""
echo "Build complete. Run scripts/05-install-env.sh to set up your environment."
