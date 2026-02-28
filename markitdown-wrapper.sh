#!/bin/bash

# markitdown-wrapper: Convert various document formats to Markdown using Docker
# Supports: PDF, DOCX, XLSX, HTML, Images, Audio, PowerPoint, RTF, and more
# Usage: markitdown-wrapper <input_file> [output_file]

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Repo path — replaced with the absolute repo path by install.sh at install time.
MARKITDOWN_REPO_PATH=""
if [ -z "$MARKITDOWN_REPO_PATH" ]; then
    MARKITDOWN_REPO_PATH="$(dirname "$(realpath "$0")")"
fi

# Usage
usage() {
    printf "%bmarkitdown-wrapper%b - Convert documents to Markdown using MarkItDown\n\n" "${BLUE}" "${NC}"
    printf "%bUSAGE:%b\n" "${YELLOW}" "${NC}"
    printf "    markitdown-wrapper <input_file> [output_file]\n\n"
    printf "%bSUPPORTED FORMATS:%b\n" "${YELLOW}" "${NC}"
    printf "    Documents:   PDF, DOCX, XLSX, PPTX, RTF, HTML\n"
    printf "    Images:      PNG, JPG, JPEG, WEBP, GIF, BMP, SVG\n"
    printf "    Audio:       MP3, WAV, FLAC, OGG, M4A\n"
    printf "    Others:      ZIP archives and more\n\n"
    printf "%bEXAMPLES:%b\n" "${YELLOW}" "${NC}"
    printf "    # Convert with auto-generated output name\n"
    printf "    markitdown-wrapper document.pdf\n"
    printf "    # Outputs: document.md\n\n"
    printf "    # Specify output file\n"
    printf "    markitdown-wrapper report.docx custom_output.md\n\n"
    printf "    # Convert image\n"
    printf "    markitdown-wrapper screenshot.png screenshot.md\n\n"
    printf "    # Convert audio\n"
    printf "    markitdown-wrapper podcast.mp3 transcript.md\n\n"
    printf "%bOPTIONS:%b\n" "${YELLOW}" "${NC}"
    printf "    -h, --help       Show this help message\n"
    printf "    -v, --verbose    Show docker command being executed\n"
    printf "    --no-clean       Don't clean up temporary files (debug mode)\n"
    printf "    -u, --update     Pull latest upstream, rebuild Docker image, reinstall\n\n"
    printf "%bENVIRONMENT:%b\n" "${YELLOW}" "${NC}"
    printf "    MARKITDOWN_IMAGE  Docker image to use (default: markitdown:latest)\n"
    printf "    MARKITDOWN_TAG    Image tag to use (default: latest)\n"
}

# Update: pull latest markitdown submodule, rebuild image, reinstall
do_update() {
    printf "%b═══════════════════════════════════════════%b\n" "${BLUE}" "${NC}"
    printf "%bMarkItDown Update%b\n" "${GREEN}" "${NC}"
    printf "%b═══════════════════════════════════════════%b\n" "${BLUE}" "${NC}"

    if [ ! -d "${MARKITDOWN_REPO_PATH}/.git" ]; then
        printf "%bError: repo not found at %s%b\n" "${RED}" "${MARKITDOWN_REPO_PATH}" "${NC}"
        printf "%bRe-install with: ./install.sh%b\n" "${YELLOW}" "${NC}"
        exit 1
    fi

    printf "%bPulling latest wrapper changes...%b\n" "${YELLOW}" "${NC}"
    git -C "${MARKITDOWN_REPO_PATH}" pull

    printf "%bUpdating markitdown submodule to latest upstream...%b\n" "${YELLOW}" "${NC}"
    git -C "${MARKITDOWN_REPO_PATH}" submodule update --remote markitdown

    printf "%bBuilding Docker image markitdown:latest...%b\n" "${YELLOW}" "${NC}"
    docker build -t markitdown:latest "${MARKITDOWN_REPO_PATH}/markitdown"

    printf "%bReinstalling wrapper...%b\n" "${YELLOW}" "${NC}"
    "${MARKITDOWN_REPO_PATH}/install.sh"

    printf "%bDone! markitdown is up to date.%b\n" "${GREEN}" "${NC}"
}

# Default values
VERBOSE=false
NO_CLEAN=false
INPUT_FILE=""
OUTPUT_FILE=""
DOCKER_IMAGE="${MARKITDOWN_IMAGE:-markitdown}"
DOCKER_TAG="${MARKITDOWN_TAG:-latest}"
FULL_IMAGE="${DOCKER_IMAGE}:${DOCKER_TAG}"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            exit 0
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        --no-clean)
            NO_CLEAN=true
            shift
            ;;
        -u|--update)
            do_update
            exit 0
            ;;
        -*)
            printf "%bError: Unknown option '$1'%b\n" "${RED}" "${NC}"
            usage
            exit 1
            ;;
        *)
            if [ -z "$INPUT_FILE" ]; then
                INPUT_FILE="$1"
            elif [ -z "$OUTPUT_FILE" ]; then
                OUTPUT_FILE="$1"
            else
                printf "%bError: Too many arguments%b\n" "${RED}" "${NC}"
                usage
                exit 1
            fi
            shift
            ;;
    esac
done

# Validate input
if [ -z "$INPUT_FILE" ]; then
    printf "%bError: Input file is required%b\n" "${RED}" "${NC}"
    usage
    exit 1
fi

# Check if input file exists
if [ ! -f "$INPUT_FILE" ]; then
    printf "%bError: Input file not found: %s%b\n" "${RED}" "${INPUT_FILE}" "${NC}"
    exit 1
fi

# Generate output filename if not provided
if [ -z "$OUTPUT_FILE" ]; then
    # Remove extension and add .md
    OUTPUT_FILE="${INPUT_FILE%.*}.md"
fi

# Check if output file already exists
if [ -f "$OUTPUT_FILE" ]; then
    printf "%bWarning: Output file already exists: %s%b\n" "${YELLOW}" "${OUTPUT_FILE}" "${NC}"
    read -p "Overwrite? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        printf "%bCancelled.%b\n" "${RED}" "${NC}"
        exit 1
    fi
fi

# Get absolute paths
INPUT_ABS=$(cd "$(dirname "$INPUT_FILE")" && pwd)/$(basename "$INPUT_FILE")
OUTPUT_ABS=$(cd "$(dirname "$OUTPUT_FILE")" 2>/dev/null || cd . && pwd)/$(basename "$OUTPUT_FILE")

# Create temporary named pipe for input if needed
TEMP_INPUT=""
if [ ! -r "$INPUT_ABS" ]; then
    printf "%bError: Cannot read input file: %s%b\n" "${RED}" "${INPUT_FILE}" "${NC}"
    exit 1
fi

# Build docker command
DOCKER_CMD="docker run --rm -i ${FULL_IMAGE}"

# Add file type hint if needed
FILE_EXT="${INPUT_FILE##*.}"
MIME_TYPE=""

case "${FILE_EXT,,}" in
    pdf) MIME_TYPE="application/pdf" ;;
    docx) MIME_TYPE="application/vnd.openxmlformats-officedocument.wordprocessingml.document" ;;
    xlsx) MIME_TYPE="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" ;;
    pptx) MIME_TYPE="application/vnd.openxmlformats-officedocument.presentationml.presentation" ;;
    html|htm) MIME_TYPE="text/html" ;;
    rtf) MIME_TYPE="application/rtf" ;;
    png) MIME_TYPE="image/png" ;;
    jpg|jpeg) MIME_TYPE="image/jpeg" ;;
    gif) MIME_TYPE="image/gif" ;;
    webp) MIME_TYPE="image/webp" ;;
    mp3) MIME_TYPE="audio/mpeg" ;;
    wav) MIME_TYPE="audio/wav" ;;
    flac) MIME_TYPE="audio/flac" ;;
    ogg|oga) MIME_TYPE="audio/ogg" ;;
    m4a) MIME_TYPE="audio/mp4" ;;
esac

# Display conversion info
printf "%b═══════════════════════════════════════════%b\n" "${BLUE}" "${NC}"
printf "%bMarkItDown Conversion%b\n" "${GREEN}" "${NC}"
printf "%b═══════════════════════════════════════════%b\n" "${BLUE}" "${NC}"
printf "Input:  %b%s%b\n" "${BLUE}" "${INPUT_FILE}" "${NC}"
printf "Output: %b%s%b\n" "${BLUE}" "${OUTPUT_FILE}" "${NC}"
printf "Format: %b%s%b\n" "${BLUE}" "${FILE_EXT,,}" "${NC}"
if [ -n "$MIME_TYPE" ]; then
    printf "MIME:   %b%s%b\n" "${BLUE}" "${MIME_TYPE}" "${NC}"
fi
printf "%b═══════════════════════════════════════════%b\n" "${BLUE}" "${NC}"

# Execute conversion
if [ "$VERBOSE" = true ]; then
    printf "%bExecuting: %s < \"%s\" > \"%s\"%b\n" "${YELLOW}" "${DOCKER_CMD}" "${INPUT_ABS}" "${OUTPUT_ABS}" "${NC}"
fi

if eval "${DOCKER_CMD}" < "$INPUT_ABS" > "$OUTPUT_ABS"; then
    FILE_SIZE=$(wc -c < "$OUTPUT_ABS")
    LINE_COUNT=$(wc -l < "$OUTPUT_ABS")
    printf "%bConversion successful!%b\n" "${GREEN}" "${NC}"
    printf "Size: %b%s%b\n" "${BLUE}" "$(numfmt --to=iec-i --suffix=B $FILE_SIZE 2>/dev/null || echo "${FILE_SIZE} bytes")" "${NC}"
    printf "Lines: %b%s%b\n" "${BLUE}" "${LINE_COUNT}" "${NC}"
else
    printf "%bConversion failed!%b\n" "${RED}" "${NC}"
    [ -f "$OUTPUT_ABS" ] && rm -f "$OUTPUT_ABS"
    exit 1
fi

printf "%bDone!%b\n" "${GREEN}" "${NC}"
