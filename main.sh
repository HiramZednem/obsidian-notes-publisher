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

cleanup_git_state() {
    git rebase --abort >/dev/null 2>&1 || true
    git merge --abort >/dev/null 2>&1 || true
    git cherry-pick --abort >/dev/null 2>&1 || true
}

create_local_commit_if_needed() {
    local STATUS_OUTPUT
    STATUS_OUTPUT="$(git status --porcelain)"

    if [[ -n "$STATUS_OUTPUT" ]]; then
        log "Changes detected; creating a local commit before pull"
        git add -A

        if git diff --cached --quiet; then
            log "No content changes to commit; repository remains valid"
            return 0
        fi

        if ! git commit -m "[BOT] $(date +'%y-%m-%d %r')"; then
            log "No new commit created; repository is still in a valid state"
        fi
    else
        log "No local changes; nothing to commit before pull"
    fi
}

sync_with_remote() {
    local CURRENT_BRANCH

    CURRENT_BRANCH="$(git symbolic-ref --quiet --short HEAD 2>/dev/null || echo "main")"

    if [[ -z "$CURRENT_BRANCH" || "$CURRENT_BRANCH" == "HEAD" ]]; then
        log "Repository is not on a named branch; skipping remote sync"
        return 0
    fi

    log "Fetching latest changes from origin/$CURRENT_BRANCH"
    git fetch origin --prune

    log "Pulling latest changes"
    if ! git pull --rebase origin "$CURRENT_BRANCH"; then
        log "Pull with rebase failed; aborting stale rebase and leaving repository unchanged"
        cleanup_git_state
        echo "--------------------------------------------------------------" >> "$LOG_FILE"
        return 1
    fi

    log "Pushing changes"
    if ! git push --set-upstream origin "$CURRENT_BRANCH"; then
        log "Push failed after a successful pull"
        echo "--------------------------------------------------------------" >> "$LOG_FILE"
        return 1
    fi

    log "Commit created and pushed successfully"
    echo "--------------------------------------------------------------" >> "$LOG_FILE"
    return 0
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

cleanup_git_state
create_local_commit_if_needed

if ! sync_with_remote; then
    exit 0
fi

exit 0
