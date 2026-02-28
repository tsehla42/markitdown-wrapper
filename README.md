# MarkItDown Wrapper

A convenient wrapper script for converting various document formats to Markdown using Microsoft's MarkItDown and Docker.

## Features

**Multi-format Support**
- **Documents**: PDF, DOCX, XLSX, PPTX, RTF, HTML
- **Images**: PNG, JPG, JPEG, WEBP, GIF, BMP, SVG  
- **Audio**: MP3, WAV, FLAC, OGG, M4A (extracts transcripts)
- **Others**: ZIP archives and more

**Convenient Interface**
- Auto-generates output filenames (removes extension, adds `.md`)
- Smart MIME type detection
- User-friendly colored output
- Confirmation before overwriting files
- Verbose mode for debugging

**Flexible Deployment**
- Use as shell function for quick tasks
- Use as installed command (`markitdown`)
- Docker-based for portability

## Installation

### 1. Clone (with submodule)

The upstream `markitdown` repo is tracked as a git submodule — it adds no weight to this repo.

```bash
git clone --recurse-submodules https://github.com/<you>/markitdown-wrapper.git
cd markitdown-wrapper
```

If you already cloned without the flag:

```bash
git submodule update --init
```

### 2. Build the Docker image

```bash
docker build -t markitdown:latest markitdown/
```

### 3. Install the wrapper

```bash
./install.sh
```

Installs to `~/.local/bin/markitdown`. Custom path:

```bash
./install.sh /usr/local/bin
```

### Option 3: Manual Installation

```bash
cp markitdown-wrapper.sh ~/.local/bin/markitdown
chmod +x ~/.local/bin/markitdown
export PATH="$PATH:$HOME/.local/bin"  # Add to ~/.bashrc or ~/.zshrc
```

### Option 4: Shell Function (Quick Setup)

Add to your `~/.bashrc` or `~/.zshrc`:

```bash
export PATH="$PATH:$HOME/.local/bin"
```

## Usage

### Basic Usage

```bash
# Auto-generate output filename
markitdown document.pdf
# Creates: document.md

# Specify custom output
markitdown input.docx output.md

# Convert images
markitdown screenshot.png description.md

# Convert audio (extracts transcript)
markitdown podcast.mp3 transcript.md
```

### Options

```bash
-h, --help       Show help message
-v, --verbose    Show docker command being executed
--no-clean       Keep temporary files (debug mode)
-u, --update     Pull latest changes & rebuild Docker image (see Updating below)
```

## Updating

```bash
markitdown -u
```

This does everything in one command:
1. `git pull` — latest wrapper changes
2. `git submodule update --remote` — latest upstream MarkItDown
3. `docker build -t markitdown:latest` — rebuild the image
4. `./install.sh` — reinstall the wrapper binary

After that the new Docker image is active for all future conversions.

### Examples

```bash
# Convert Word document
markitdown report.docx

# Convert spreadsheet with custom output
markitdown data.xlsx data_formatted.md

# Convert HTML page
markitdown webpage.html page.md

# Convert presentation
markitdown slides.pptx summary.md

# Convert image (OCR)
markitdown invoice.png invoice_text.md

# Verbose mode to see docker command
markitdown -v document.pdf
```

## Configuration

### Docker Image

By default, uses `markitdown:latest`. Override with environment variables:

```bash
# Use specific image
export MARKITDOWN_IMAGE=my-markitdown
export MARKITDOWN_TAG=v1.0.0
markitdown file.pdf

# Or inline
MARKITDOWN_IMAGE=custom MARKITDOWN_TAG=latest markitdown file.pdf
```

### Requirements

- Docker installed and running
- MarkItDown Docker image available locally or accessible via Docker Hub
- Read/write permissions in current directory

## Building the Docker Image

If you need to build the markitdown image:

```bash
# Using official Microsoft MarkItDown
docker build -t markitdown:latest https://github.com/microsoft/markitdown.git

# Or using a pre-built image
docker pull mcr.microsoft.com/markitdown:latest
```

## Supported Formats

### Documents
| Format | Extension | Notes |
|--------|-----------|-------|
| PDF | `.pdf` | Full text extraction with layout preservation |
| Word | `.docx` | Complete document structure conversion |
| Excel | `.xlsx` | Tables and formatting preserved |
| PowerPoint | `.pptx` | Slide content and structure |
| HTML | `.html`, `.htm` | Web pages and HTML files |
| RTF | `.rtf` | Rich text format |
| Markdown | `.md` | Already markdown, but can reformat |

### Images
| Format | Extension | Notes |
|--------|-----------|-------|
| PNG | `.png` | OCR supported |
| JPEG | `.jpg`, `.jpeg` | OCR supported |
| WebP | `.webp` | OCR supported |
| GIF | `.gif` | First frame extracted |
| BMP | `.bmp` | OCR supported |
| SVG | `.svg` | Vector preservation |

### Audio
| Format | Extension | Notes |
|--------|-----------|-------|
| MP3 | `.mp3` | Transcript extraction |
| WAV | `.wav` | Transcript extraction |
| FLAC | `.flac` | Transcript extraction |
| OGG | `.ogg`, `.oga` | Transcript extraction |
| M4A | `.m4a` | Transcript extraction |

## Troubleshooting

### Docker not found
```bash
# Install Docker if not already installed
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
```

### Image not found
```bash
# Ensure markitdown image is available
docker pull mcr.microsoft.com/markitdown:latest
docker tag mcr.microsoft.com/markitdown:latest markitdown:latest
```

### Permission denied
```bash
# Make script executable
chmod +x markitdown-wrapper.sh
chmod +x install.sh
```

### Cannot read input file
```bash
# Check file permissions
ls -l yourfile.pdf
chmod +r yourfile.pdf
```

### Output file permission denied
```bash
# Ensure write permissions in directory
ls -ld .
chmod u+w .
```

## Performance Tips

### Stream Processing

```bash
# Original docker command still works
docker run --rm -i markitdown:latest < input.pdf > output.md

# But now you can also use the wrapper
markitdown input.pdf output.md
```

## Project Structure

```
markitdown-wrapper/
├── markitdown-wrapper.sh  # Main wrapper script
├── install.sh             # Installation script
├── README.md             # This file
```

## References

- [Microsoft MarkItDown](https://github.com/microsoft/markitdown)
- [Docker Documentation](https://docs.docker.com/)

## Support

For issues with the wrapper script, check:
- `markitdown --help` - View available options
- `markitdown -v <file>` - Run in verbose mode to see docker command
- Docker logs: `docker logs <container_id>`
