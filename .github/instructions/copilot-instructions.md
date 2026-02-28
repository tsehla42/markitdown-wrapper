---
applyTo: "**"
---

# markitdown-wrapper

A bash wrapper around Microsoft's [MarkItDown](https://github.com/microsoft/markitdown) Docker image. Converts documents, images, and audio to Markdown via stdin/stdout piping.

## Architecture

Two-file project:

- `markitdown-wrapper.sh` — main converter script, installed as `markitdown` in the user's PATH
- `install.sh` — copies `markitdown-wrapper.sh` to `~/.local/bin/markitdown` (never run with sudo)

The wrapper pipes input files into Docker via stdin and captures stdout as the `.md` output:
```bash
docker run --rm -i markitdown:latest < input.pdf > output.md
```

## Install / Reinstall

```bash
./install.sh                  # installs to ~/.local/bin/markitdown
./install.sh /custom/path     # custom install path
```

Never use `sudo ./install.sh` — it would install to `/root/.local/bin` instead of the user's home.

`install.sh` embeds the absolute repo path into the installed binary at install time using `sed`. This is what makes `markitdown -u` work from anywhere. After editing `markitdown-wrapper.sh`, always re-run `./install.sh` to update the installed binary.

## Submodule

The upstream MarkItDown repo is tracked as a git submodule at `markitdown/`. Clone with:

```bash
git clone --recurse-submodules <repo-url>
```

Do not commit files inside `markitdown/` — only the submodule pointer is tracked.

## Updating (`-u` flag)

`markitdown -u` runs: `git pull` on the wrapper repo → `git submodule update --remote markitdown` → `docker build -t markitdown:latest markitdown/` → `./install.sh`.

The `do_update()` function is defined near the top of `markitdown-wrapper.sh`, before the argument parser. It relies on `MARKITDOWN_REPO_PATH` (see below).

## MARKITDOWN_REPO_PATH

`markitdown-wrapper.sh` contains `MARKITDOWN_REPO_PATH=""`. At install time `install.sh` replaces that empty-string assignment with the absolute repo path using `sed` (matching the full assignment string, not a placeholder). If `MARKITDOWN_REPO_PATH` is still empty (i.e. the script is run directly from the repo, not installed), it falls back to `$(dirname "$(realpath "$0")")`.



Output colors use `printf "%b...%b" "${COLOR}" "${NC}"`, not `echo -e`. The color variables (`RED`, `GREEN`, `YELLOW`, `BLUE`, `NC`) are defined at the top of each script. Always use this pattern when adding new output lines — `echo -e` does not reliably handle ANSI escapes here.

Default Docker image is `markitdown:latest`, overridable via env vars:
```bash
MARKITDOWN_IMAGE=my-image MARKITDOWN_TAG=v2 markitdown file.pdf
```

Output filename is auto-derived by stripping the input extension and appending `.md`. The `${INPUT_FILE%.*}.md` pattern is used throughout.

## Supported Input Formats

Documents: PDF, DOCX, XLSX, PPTX, RTF, HTML  
Images (with OCR): PNG, JPG, JPEG, WEBP, GIF, BMP, SVG  
Audio (transcript): MP3, WAV, FLAC, OGG, M4A  

MIME types are detected by file extension in a `case` block around line 145 of `markitdown-wrapper.sh`. Add new formats there.

## Adding Features

- All user-facing output must use `printf` with color vars, never `echo -e`
- New CLI flags go in the `while [[ $# -gt 0 ]]; do case $1 in` block
- `set -e` is active — any unchecked command failure exits immediately
- The installed binary at `~/.local/bin/markitdown` is a copy; re-run `./install.sh` after editing `markitdown-wrapper.sh`
