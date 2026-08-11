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

STATUS_OUTPUT="$(git status --porcelain)"

if [[ -n "$STATUS_OUTPUT" ]]; then
    log "Changes detected; creating a local commit before pull"
    git add .

    if ! git commit -m "[BOT] $(date +'%y-%m-%d %r')"; then
        log "No new commit created; repository is still in a valid state"
    fi
else
    log "No local changes; nothing to commit before pull"
fi

log "Pulling latest changes"
if ! git pull --rebase; then
    log "Conflict detected during pull; aborting rebase and leaving repository unchanged"
    git rebase --abort >/dev/null 2>&1 || true
    echo "--------------------------------------------------------------" >> "$LOG_FILE"
    exit 0
fi

log "Pushing changes"
if ! git push; then
    log "Push failed after a successful pull"
    echo "--------------------------------------------------------------" >> "$LOG_FILE"
    exit 1
fi

log "Commit created and pushed successfully"
echo "--------------------------------------------------------------" >> "$LOG_FILE"

exit 0
