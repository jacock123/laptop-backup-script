#!/bin/bash

# ====== Password-Input ======
echo "This Password is used to encrypt youre backup. Remember it to restore youre backup"
read -s -p "🔐 Please enter youre encryption password: " ENC_PASS # password to encrypt/decrypt the password
echo

# ====== Generate Timestamp ======
TIMESTAMP=$(date +"%Y-%m-%d-%H-%M")
ZIP_FILENAME="backup_$TIMESTAMP.zip"
ZIP_FILEPATH="/tmp/$ZIP_FILENAME"

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




check() {
    # Check if the Remote Device is reachable over the network
    echo "Checking if youre server is availeble over the network"
    ping -c 3 "$RASPBERRY_PI_IP"
    if [ "$?" = 1 ]; then
	echo "Server can not be reached. NOT BACKED UP!"
        echo "$TIMESTAMP -- server could not be reached" >> $LOG_FILEPATH
        exit 1
    else
        # Check if the devices Battery is above 20%, if not: exit script
	echo "Checking if this device Battery is above 20%"
        value=$(upower -i /org/freedesktop/UPower/devices/battery_BAT0 | \
            grep -i percentage | \
                awk '{print $2}' | \
                    tr -d '%':)
        if (( $value < 20 )); then
            echo "$TIMESTAMP -- battery too low, cancelling operation" \
	    echo "Battery is too low, cancelling backup"
                >> $LOG_FILEPATH
            exit 1
        else
	    echo "Battery percentage at a good level, continuing backup"
            echo "$TIMESTAMP -- Battery percentage at correct level, continuing operation" \
                >> $LOG_FILEPATH
        fi
    fi

    backup
}



backup() {
    # ====== create zip file ======
    echo "Creating ZIP File: $ZIP_FILEPATH"
    zip -r "$ZIP_FILEPATH" "${INCLUDE_PATHS[@]}" -x "${EXCLUDE_PATHS[@]}"
    echo "$TIMESTAMP -- zip file created" >> $LOG_FILEPATH
    echo "ZIP File Created"

    # ====== encrypting Backup file ======
    echo "Encrypting zip file"
    openssl enc -aes-256-cbc -pbkdf2 -iter 600000 -k "$ENC_PASS" -in "$ZIP_FILEPATH" -out "$ENC_OUTPUT_PATH"
    echo "$TIMESTAMP -- generated encrypted export file" >> $LOG_FILEPATH
    echo "ZIP File encrypted"

    # ====== upload zip file ======
    echo "Uploading enc file to server"
    rsync -avz --progress "$ENC_OUTPUT_PATH" "${RASPBERRY_PI_USER}@${RASPBERRY_PI_IP}:${REMOTE_BACKUP_DIR}/"
    echo "$TIMESTAMP -- enc file was transferred" >> $LOG_FILEPATH
    echo "enc file uploaded"

    # ====== shred local files ======
    echo "Shredding local zip and enc file"
    shred -n 10 -u "$ENC_OUTPUT_FILE"
    shred -n 10 -u "$ZIP_FILEPATH"
    echo "$TIMESTAMP -- removed local zip file" >> $LOG_FILEPATH
    echo "local zip and enc file shredded 10 times"

    echo "Backup done: $ENC_OUTPUT_FILE is now on the server: $REMOTE_BACKUP_DIR"
    echo "$TIMESTAMP -- backup executed successfully" >> $LOG_FILEPATH
}
check
