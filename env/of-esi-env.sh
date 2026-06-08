#!/bin/bash
# ESI OpenFOAM v2512 native macOS environment
# Source on a case-sensitive APFS volume (/Volumes/OpenFOAM-ESI) to avoid
# macOS case-insensitive FS collisions (dictionary.H/Dictionary.H, etc.)

export FOAM_INST_DIR="/Volumes/OpenFOAM-ESI"

source "$FOAM_INST_DIR/OpenFOAM-v2512/etc/bashrc" \
    WM_COMPILER=Clang \
    WM_MPLIB=SYSTEMOPENMPI \
    FOAM_INST_DIR="/Volumes/OpenFOAM-ESI"

# Homebrew paths
export PATH="/opt/homebrew/opt/flex/bin:$PATH"
export LDFLAGS="-L/opt/homebrew/opt/flex/lib $LDFLAGS"
export CPPFLAGS="-I/opt/homebrew/opt/flex/include $CPPFLAGS"

export MPI_ROOT=/opt/homebrew/opt/open-mpi
export MPI_ARCH_FLAGS="-DOMPI_SKIP_MPICXX"
export MPI_ARCH_INC="-I$MPI_ROOT/include"
export MPI_ARCH_LIBS="-L$MPI_ROOT/lib -lmpi"

# Force libc++ headers to be found before OpenFOAM's lnInclude on macOS.
# Without this, <cwchar> finds OpenFOAM's wchar.h (case-insensitive FS sees
# wchar.H as wchar.h) instead of libc++'s internal wchar.h, causing build failure.
SDK_PATH=$(xcrun --show-sdk-path 2>/dev/null)
export FOAM_EXTRA_CXXFLAGS="-I${SDK_PATH}/usr/include/c++/v1"

echo "ESI OpenFOAM v2512 (darwin64Clang) environment loaded"
