#!/bin/bash

set -uo pipefail

source "$HOME/.profile"

log() {
    local MESSAGE="$1"
    local DATE
    DATE="$(date +'%y-%m-%d %r')"

    echo "[$DATE] $MESSAGE" | tee -a "$LOG_FILE"
}

handle_error() {
    local EXIT_CODE=$?
    local LINE_NO=$1

    log "ERROR: Script failed at line $LINE_NO with exit code $EXIT_CODE"
    echo "--------------------------------------------------------------" >> "$LOG_FILE"

    exit $EXIT_CODE
}

trap 'handle_error $LINENO' ERR

require_directory() {
    local PATH_DIRECTORY="$1"

    if [[ ! -d "$PATH_DIRECTORY" ]]; then
        echo "ERROR: Directory '$PATH_DIRECTORY' doesn't exist"
        exit 1
    fi
}

require_command() {
    local COMMAND="$1"

    if ! command -v "$COMMAND" >/dev/null 2>&1; then
        echo "ERROR: Required command '$COMMAND' is not installed"
        exit 1
    fi
}

# Validate env vars
if [[ -z "${OBSIDIAN_NOTES_FOLDER:-}" ]]; then
    echo "ERROR: OBSIDIAN_NOTES_FOLDER is not set"
    exit 1
fi

if [[ -z "${OBSIDIAN_NOTES_PUBLISHER_LOG_FILE:-}" ]]; then
    echo "ERROR: OBSIDIAN_NOTES_PUBLISHER_LOG_FILE is not set"
    exit 1
fi

GIT_FOLDER="$OBSIDIAN_NOTES_FOLDER"
LOG_FILE="$OBSIDIAN_NOTES_PUBLISHER_LOG_FILE"
LOG_FILE_DIRNAME="$(dirname "$LOG_FILE")"

require_directory "$GIT_FOLDER"
require_directory "$LOG_FILE_DIRNAME"

require_command git

# Ensure log file exists
touch "$LOG_FILE"

log "Running Obsidian-Notes-Publisher Script"

cd "$GIT_FOLDER"

log "Pulling latest changes"
git pull

STATUS_OUTPUT="$(git status --porcelain)"

if [[ -z "$STATUS_OUTPUT" ]]; then
    log "Nothing to commit"
    echo "--------------------------------------------------------------" >> "$LOG_FILE"
    exit 0
fi

log "Changes detected"

git add .

git commit -m "[BOT] $(date +'%y-%m-%d %r')"

log "Pushing changes"
git push

log "Commit created and pushed successfully"
echo "--------------------------------------------------------------" >> "$LOG_FILE"

exit 0
