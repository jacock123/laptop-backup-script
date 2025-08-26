# laptop-backup-script

Backup Script, to backup laptop to my File Server

---

### Requirements

- Linux for main operating system
- Installed all on main operating system "Used Tools"
- Linux Server where the Backup should go

---

### Used Tools

- shred
- ping
- upower
- grep
- zip
- openssl
- rsync

---

### Configuring the Script

Every path must exist before running the script

You need to customize the first parts that look like this:

```bash
# ====== create logs ======
LOG_FILENAME="linuxbackuplogs" # name of local log file
LOG_FILEPATH="/log/dir/$LOG_FILENAME" # path to log dir

# ====== server configuration ======
RASPBERRY_PI_USER="YoureServerUsername" # youre server username
RASPBERRY_PI_IP="1234.1234.1234.1234" # the ip of youre server
REMOTE_BACKUP_DIR="/backup/dir" # the path where youre backup should go
export ENC_PASS

# ====== pathes to secure ======
INCLUDE_PATHS=(
    # pathes that are included in youre backup
    "/path1/to/include/to/backup"
    "/path2/to/include/to/backup"
    "/path3/to/include/to/backup"
)

EXCLUDE_PATHS=(
    # pathes that are excluded from youre backup
    "/path1/to/exclude/from/backup"
    "/path2/to/exclude/from/backup"
    "/path3/to/exclude/from/backup"
)
```

---

Have fun!
