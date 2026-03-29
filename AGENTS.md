# AGENTS.md

This document provides guidelines for agents working on this codebase.

## Project Overview

This repository contains bash scripts for taking screenshots, uploading them to a remote server, and copying the resulting URL to the clipboard. There are three variants:
- `public-screenshot.sh` - full screen capture
- `public-screenshot-area.sh` - area/region selection capture
- `mc-public-screenshot-area.sh` - area capture using MinIO client instead of rsync

## Nix Flake

A `flake.nix` is provided for declarative development environments. To enter a shell with all dependencies:

```bash
nix develop
```

## Build/Test Commands

### Linting with shellcheck
```bash
shellcheck public-screenshot.sh public-screenshot-area.sh mc-public-screenshot-area.sh
```
All scripts are linted with [shellcheck](https://www.shellcheck.net/).

### Syntax check only
```bash
bash -n script.sh
```

### Manual testing
Test on supported environments:
- X11 (any desktop environment)
- Wayland (Sway, Hyprland, KDE Plasma Wayland, etc.)

## Code Style Guidelines

### Shellcheck Directives
- Use `shellcheck disable=SCXXXX` for intentional deviations
- All source directives must reference the env file: `# shellcheck source=./public-screenshot.env`

### Bash Shebang
Always use `#!/bin/bash` (not `#!/bin/sh`).

### Variable Naming
- Environment variables sourced from config: uppercase (e.g., `LOCALPATH`, `SSHSRV`)
- Local/script variables: lowercase with underscores (e.g., `fil_name`, `fil_extension`)
- Constants: uppercase with underscores (e.g., `FIL_EXTENSION='png'`)

### Quoting
- Always quote variables containing paths: `"${LOCALPATH}"`
- Use single quotes for literal strings: `'png'`
- Use double quotes for variable expansion: `"${DATE}${RANDOM}"`

### Exit Codes
- `0` - success
- `255` - unrecognized desktop environment (handled in the `*` case)
- Other non-zero codes indicate specific failures

### Functions
Not currently used in this codebase. If added:
- Use `function_name()` syntax
- Prefer `local` variables inside functions
- Always handle error cases explicitly

### Error Handling Patterns
```bash
# Safe cd with error reporting
cd "${LOCALPATH}" || ( echo -n "Couldn't 'cd' into ${LOCALPATH}" | ${COPYCMD} && exit 1 )

# Command failure with notification
rsync "${LOCALPATH}/${FIL}" "${SSHSRV}":"${REMOTEFILE}" || ( echo -n "Rsync failed!!" | ${COPYCMD} && exit 1 )
```

### Conditional Notifications
Use the `[[ ${VAR:-} ]]` pattern for optional execution:
```bash
[[ ${DENOTIFY:-} ]] && ${DENOTIFY} "${FILEURL}"
```

### Command Substitution
Prefer `$()` over backticks:
```bash
FIL_NAME="$(echo "${DATE}${RANDOM}" | sha256sum | (read -ra FILAR; echo "${FILAR[0]}" ))"
```

### Case Statements
Used for clipboard tool detection. Pattern:
```bash
case $XDG_SESSION_TYPE in
  'wayland')
    COPYCMD='wl-copy'
    ;;
  'x11')
    COPYCMD='xsel -i'
    ;;
  *)
    exit 255
    ;;
esac
```

### Arrays
When using read with arrays:
```bash
read -ra ARRAY <<< "$input"
echo "${ARRAY[0]}"
```

## Git Commit Conventions

Use prefixes in commit messages:
- `[+]` - new feature or addition
- `[-]` - removal or deletion
- `[~]` - modification/refactor
- `[#]` - bug fix

Examples:
```
[+] add notify-send to gnomewayland
[~] updated for gnome on wayland
[-] clean up
```

## File Structure

```
.
├── flake.nix                      # Nix flake for development environment
├── flake.lock                     # Nix lock file (generated)
├── public-screenshot.sh           # Full screen capture
├── public-screenshot-area.sh     # Area selection capture (rsync)
├── mc-public-screenshot-area.sh  # Area selection capture (MinIO)
├── public-screenshot.env         # Configuration (gitignored)
├── example.public-screenshot.env  # Example configuration
└── README.md
```

## Dependencies

- **Screenshot**: `flameshot` (works on both X11 and Wayland)
- **Clipboard**: `wl-copy` (Wayland) or `xsel` (X11)
- **Upload**: `rsync` via SSH or `mc` (MinIO client)

## Configuration

Configuration is stored in `public-screenshot.env` with these variables:
- `LOCALPATH` - local directory for temporary screenshots
- `SSHSRV` - SSH alias/host for rsync uploads
- `SRV` - public domain for URL generation
- `REMOTEPATH` - remote directory path
- `SRVPATH` - URL path segment

For MinIO variant (`mc-public-screenshot-area.sh`):
- `MCSRV` - MinIO server alias

## Flameshot Commands

- Full screen: `flameshot screen -p "${LOCALPATH}"`
- Area selection: `flameshot gui -p "${LOCALPATH}"`
