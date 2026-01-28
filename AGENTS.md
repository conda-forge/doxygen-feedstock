# AGENTS.md

## Project Overview
This is a conda-forge **feedstock** repository that builds and distributes the Doxygen package across multiple platforms (Linux, macOS, Windows) through conda. It's NOT the doxygen source code—it's a recipe and CI/CD configuration for packaging doxygen.

## Key Architecture

### Core Files Structure
- **recipe/meta.yaml**: Conda recipe defining package metadata, dependencies, build/test steps, and version (uses Jinja2 templating)
- **recipe/build.sh**: Unix/macOS build script using CMake
- **recipe/bld.bat**: Windows build script with extensive tooling validation
- **conda-forge.yml**: Conda-forge specific settings (build platforms, output validation)
- **azure-pipelines.yml**: CI orchestration (multi-platform builds on Azure)

### Version Naming Convention
Doxygen uses underscores in release tags (e.g., `Release_1_16_1`). The recipe version variable uses underscores (`version: "1_16_1"`), which get replaced when constructing the GitHub source URL.

## Critical Workflows

### Updating to a New Doxygen Version
1. Edit [recipe/meta.yaml](recipe/meta.yaml): Update `{% set version = "1_16_1" %}` and `sha256` hash
2. Reset build number to `0` if version changed
3. Run local build: `python build-locally.py` (selects config interactively)
4. Submit PR from a fork branch (NOT main repository branches)

### Local Testing
```bash
# Interactive config selection
python build-locally.py

# Specific platform (list from .ci_support/*.yaml)
python build-locally.py linux_64

# With filter
python build-locally.py --filter linux_*
```

**macOS requirement**: Set `OSX_SDK_DIR` to absolute path before building osx configs

### Platform-Specific Patches
- **fix_osx.diff**: Removes hardcoded MACOSX_DEPLOYMENT_TARGET (applied to all platforms)
- **macos.patch**: Fixes filesystem compatibility for older macOS versions (applied only on `[osx]` selector)

## Project-Specific Conventions

### Conda Selectors in meta.yaml
Use bracket syntax for platform conditionals:
```yaml
- bison  # [not win]
- winflexbison  # [win]
- macos.patch  # [osx]
```

### Build Number Bumping
- Increment `build.number` for recipe-only changes (no version update)
- Reset to `0` when `version` changes

### Test Validation
Tests run inside build step via `make tests` (Unix) or implicitly on Windows. Post-install tests verify executable versions:
```yaml
test:
  commands:
    - doxygen --version | grep {{ version }}  # [not win]
```

### Cross-Compilation Handling
See [recipe/build.sh](recipe/build.sh#L15-L17): Tests conditionally skipped when cross-compiling without emulator support.

## CI/CD Integration
- **Azure Pipelines**: Primary CI (all platforms)
- Branches in main repo immediately build and upload—use fork branches for PRs
- CI auto-generates configuration via conda-smithy: `conda smithy rerender` updates `.azure-pipelines/`, `.ci_support/`, `.scripts/`

## External Dependencies
- **conda-smithy**: Regenerates CI configs from conda-forge.yml
- **conda-build**: Builds conda packages (implicit via CI scripts)
- Upstream: https://github.com/doxygen/doxygen
