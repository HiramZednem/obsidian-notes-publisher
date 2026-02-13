# OBSIDIAN-NOTES-PUBLISHER

> Automatically syncs your Obsidian notes with a Git repository by pulling updates and creating commits when changes are detected.

---

## 🚀 Overview

I am an Obsidian user who works across multiple devices. One of the main challenges I faced was reliably tracking and backing up changes to my notes.

Since Obsidian stores notes as `.md` files, I decided to leverage Git as a version control and backup solution. This script automates the synchronization process by keeping your notes repository updated.

Once configured, the script will:
- Pull the latest changes from the remote repository
- Detect local modifications
- Automatically create commits when changes are found

The script is designed to run periodically (for example, every night using `cron`) to keep your notes synchronized without manual intervention.

---

## ✨ Key Features

- Automatic repository synchronization
- Pulls latest remote changes
- Detects and commits local changes
- Designed for scheduled automation via cron
- Lightweight and simple configuration

---

## 📦 Installation

### Prerequisites

You must define the following environment variables inside your `~/.profile` file:

- `OBSIDIAN_NOTES_FOLDER` → Path to your Obsidian vault
- `OBSIDIAN_NOTES_PUBLISHER_LOG_FILE` → Path to the log file

Example:

```bash
export OBSIDIAN_NOTES_FOLDER="$HOME/path-to-your-vault"
export OBSIDIAN_NOTES_PUBLISHER_LOG_FILE="$HOME/obsidian-publisher.log"
```

