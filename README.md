# MarkItDown Wrapper

A convenient wrapper script for converting various document formats to Markdown using Microsoft's [MarkItDown](https://github.com/microsoft/markitdown) and [Docker](https://docs.docker.com/).

The official command `markitdown` uses Python with self managed dependancies, while this wrapper is made specifically to use the Docker version of the app, to be the most plug and play as possible.

## Features

Basically all features of MarkItDown.

**Convenient Interface**
- Auto-generates output filenames (removes extension, adds `.md`)
- Smart MIME type detection
- User-friendly colored output
- Confirmation before overwriting files
- Verbose mode for debugging
- 
## Installation

```bash
git clone --recurse-submodules https://github.com/<you>/markitdown-wrapper.git
cd markitdown-wrapper
docker build -t markitdown:latest markitdown/
./install.sh
```

Installs to `~/.local/bin/markitdown`. Pass a custom path as the first argument to `install.sh`.

## Usage

```bash
markitdown document.pdf           # outputs document.md
md document.pdf                  # shorter alias, identical behaviour
markitdown report.docx out.md    # custom output name
markitdown -v slide.pptx         # verbose (shows docker command)
markitdown -u                    # update & rebuild (see below)
```

**Options**

| Flag | Description |
|------|-------------|
| `-h, --help` | Show help |
| `-v, --verbose` | Print the docker command |
| `--no-clean` | Keep temp files |
| `-u, --update` | Pull latest changes, rebuild image, reinstall |

**Supported formats:** PDF, DOCX, XLSX, PPTX, RTF, HTML, PNG, JPG, WEBP, GIF, BMP, SVG, MP3, WAV, FLAC, OGG, M4A

## Updating

```bash
markitdown -u
```

Runs: `git pull` → `git submodule update --remote` → `docker build` → `./install.sh`

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `MARKITDOWN_IMAGE` | `markitdown` | Docker image name |
| `MARKITDOWN_TAG` | `latest` | Docker image tag |
