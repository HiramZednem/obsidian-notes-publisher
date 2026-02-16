#!/bin/bash
source "$HOME/.profile"

require_directory() {
    local PATH_DIRECTORY=$1
    if [[ ! -d "$PATH_DIRECTORY" ]]; then
        echo "$PATH_DIRECTORY doesn't exist"
        exit 1
    fi
}

GIT_FOLDER=$OBSIDIAN_NOTES_FOLDER
LOG_FILE=$OBSIDIAN_NOTES_PUBLISHER_LOG_FILE
LOG_FILE_DIRNAME="$(dirname $LOG_FILE)"
DATE="$(date +'%y-%m-%d %r')"

require_directory $GIT_FOLDER
require_directory $LOG_FILE_DIRNAME

cd $GIT_FOLDER

git pull

if [[ ! -f "$LOG_FILE" ]]; then
    touch $LOG_FILE
fi

echo "[$DATE] Running Obsidian-Notes-Publisher Script" >> "$LOG_FILE"

STATUS_OUTPUT="$(git status)"
PATTERN='nothing to commit,'

if [[ $STATUS_OUTPUT =~ $PATTERN ]]; then
    echo "[$DATE] Nothing to commit" >> "$LOG_FILE"
    echo "--------------------------------------------------------------" >> "$LOG_FILE"
    exit 0
fi

git add .

git commit -m "[BOT] $DATE"

git push

echo "[$DATE] Commit created and pushed" >> "$LOG_FILE"
echo "--------------------------------------------------------------" >> "$LOG_FILE"
exit 0
