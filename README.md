# ESI OpenFOAM v2512 — Native macOS Apple Silicon Build

Native build of [ESI OpenFOAM v2512](https://www.openfoam.com) for macOS on Apple Silicon (M1/M2/M3/M4). No Docker required.

Validated on: **Mac mini M4, macOS Sequoia 15, Clang 17, Open MPI 5.0.9**

## What this repo provides

- **Patch** against the upstream ESI OpenFOAM v2512 source that makes it compile and run natively on macOS Apple Silicon
- **Scripts** to automate the full build from a fresh machine
- **Environment helpers** to load the toolchain in any shell

## Prerequisites

Install Xcode Command Line Tools:

```bash
xcode-select --install
```

Install Homebrew dependencies:

```bash
brew install open-mpi flex libomp cmake boost
```

An account at [develop.openfoam.com](https://develop.openfoam.com) is required to clone the ESI source.

## Build steps

### 1. Create the case-sensitive volume

macOS's default filesystem is case-insensitive; OpenFOAM requires case-sensitivity. This creates a 15 GB sparse image mounted at `/Volumes/OpenFOAM-ESI`:

```bash
bash scripts/01-create-volume.sh
```

### 2. Clone the source

```bash
bash scripts/02-clone.sh
```

### 3. Apply patches

```bash
bash scripts/03-apply-patches.sh
```

### 4. Build

```bash
bash scripts/04-build.sh
```

This takes 60–90 minutes on an M4 Mac mini. A full build log is written to `/Volumes/OpenFOAM-ESI/build.log`.

### 5. Install environment helpers

```bash
bash scripts/05-install-env.sh
```

This installs:
- `~/of-esi-env.sh` — source this to load the OpenFOAM environment in any shell
- A LaunchAgent that auto-mounts the sparse image at every login

## Daily use

```bash
source ~/of-esi-env.sh
simpleFoam -case /path/to/case
```

The sparse image mounts automatically at login. To mount manually:

```bash
hdiutil attach ~/openfoam/ESI/openfoam-esi-cs.sparseimage -quiet
```

## What the patches fix

All changes are against the unmodified upstream ESI OpenFOAM v2512 source at tag `OpenFOAM-v2512`. Run `git diff` inside `/Volumes/OpenFOAM-ESI/OpenFOAM-v2512` to inspect them, or read `patches/0001-openfoam-v2512-macos-apple-silicon.patch` directly.

Key fixes:

- **`wmake/rules/darwin64Clang/c++`** — Removed `-ftrapping-math` (causes Clang to reject floating-point operations that are valid under IEEE 754 but trigger hardware traps; breaks several solvers at compile time on macOS). Added Homebrew libomp paths for OpenMP support (`-I/opt/homebrew/opt/libomp/include`, `-L/opt/homebrew/opt/libomp/lib`).

- **`wmake/rules/darwin64Clang/general`** — Replaced `-I.`/`-IlnInclude` with `-iquote .`/`-iquote lnInclude`. On macOS, Clang's `-I` flag searches system include paths in addition to the specified path, causing the case-insensitive FS collision between OpenFOAM headers (e.g. `wchar.H`) and libc++ headers (e.g. `wchar.h`). `-iquote` restricts the search to quoted `#include "..."` forms only, avoiding the collision.

- **`wmake/makefiles/general`** — Replaced `-I.`/`-IlnInclude` with `-iquote` equivalents for the same reason as above.

- **`src/finiteVolume/cfdTools/general/include/fvCFD.H`** — Added `#include "localEulerDdtScheme.H"` required by Clang's stricter header dependency resolution (GCC resolves it transitively; Clang does not).

- **`src/fileFormats/Make/options`** — Added Homebrew flex include path (`-I/opt/homebrew/opt/flex/include`) so the lexer header is found during compilation.

- **`applications/solvers/*/Make/options` (38 files)** — Added `-I.` to `EXE_INC` for each affected solver. Clang requires an explicit self-include path when a solver's source includes headers from its own directory using `"..."` syntax; GCC finds them implicitly.

- **`src/thermophysicalModels/reactionThermo/Make/options`** — Same `-iquote` fix as wmake/rules for the reacting thermo library.

## cfMesh

To build cfMesh against this native installation, see [cfmesh-openfoam-v2512-apple-silicon](https://github.com/andrewcoyle1/cfmesh-openfoam-v2512-apple-silicon).

## Related

- [openfoam11-apple-silicon](https://github.com/andrewcoyle1/openfoam11-apple-silicon) — Native build of OpenFOAM Foundation v11 for macOS Apple Silicon
