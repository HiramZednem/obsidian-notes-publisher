#!/bin/bash
# git pull
validateDirname() {
    local PATH_DIRECTORY=$1
    if [[ ! -d "$PATH_DIRECTORY" ]]; then
        echo "$PATH_DIRECTORY doesn't exist"
        exit 1
    fi
}

GIT_FOLDER="/home/hiram/Documents/projects/obsidian-notes-publisher/test-folder"
validateDirname $GIT_FOLDER

cd $GIT_FOLDER

LOG_FILE="/home/hiram/Documents/projects/obsidian-notes-publisher/activity.log"
LOG_FILE_DIRNAME="$(dirname $LOG_FILE)"
validateDirname $LOG_FILE_DIRNAME

if [[ ! -f "$LOG_FILE" ]]; then
    touch $LOG_FILE
fi

DATE="$(date +'%y-%m-%d %r')"

echo "[$DATE] Running Obsidian-Notes-Publisher Script" >> "$LOG_FILE"

STATUS_OUTPUT="$(git status)"
PATTERN='nothing to commit,'

if [[ $STATUS_OUTPUT =~ $PATTERN ]]; then
    echo "[$DATE] Nothing to commit" >> "$LOG_FILE"
    echo "--------------------------------------------------------------" >> "$LOG_FILE"
    exit 0
fi

git add .

COMMIT_CMD=$(printf 'git commit -m "[BOT] %s"' "$DATE")
eval $COMMIT_CMD

git push

echo "[$DATE] Commit created and pushed" >> "$LOG_FILE"
echo "--------------------------------------------------------------" >> "$LOG_FILE"
exit 0
