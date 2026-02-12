#!/bin/bash
# TODO: add a git pull part

GIT_FOLDER="/home/hiram/Documents/projects/obsidian-notes-publisher/test-folder"
LOG_FILE="/home/hiram/Documents/projects/obsidian-notes-publisher/activity.log"

DATE="$(date +'%y-%m-%d %r')"

cd $GIT_FOLDER
# TODO: add validation in case that doesn't exit....

echo "[$DATE] Running Script" >> "$LOG_FILE"

STATUS_OUTPUT="$(git status)"
PATTERN='nothing to commit,'

if [[ $STATUS_OUTPUT =~ $PATTERN ]]; then
    echo "[$DATE] Nothing to commit" >> "$LOG_FILE"
    echo "---------------------------------------------------" >> "$LOG_FILE"
else
    git add .
    # TODO: add validations

    COMMIT_CMD=$(printf 'git commit -m "%s"' "$DATE")
    eval $COMMIT_CMD

    
    git push
    # TODO: add validaions

    echo "[$DATE] Commit created and pushed" >> "$LOG_FILE"
    echo "---------------------------------------------------" >> "$LOG_FILE"
    
fi


# date +"%y-%m-%d %r"