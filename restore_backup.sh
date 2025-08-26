# ====== Server details ======
RASPBERRY_PI_USER="YoureServerUsername" # youre server username
RASPBERRY_PI_IP="1234.1234.1234.1234" # the ip of youre server
REMOTE_BACKUP_DIR="/backup/dir" # the path where youre backup should go
LOCAL_DESKTOP_DIR="$HOME/Desktop" # folder where the backup goes

# ====== searching newest backup folder ======
echo "Searching for the newest backup folder on the server"
LATEST_DIR=$(ssh ${RASPBERRY_PI_USER}@${RASPBERRY_PI_IP} \
    "ls -1dt ${REMOTE_BACKUP_DIR}/[0-9]* 2>/dev/null | head -n 1")

if [ -z "$LATEST_DIR" ]; then
    echo "No backup folder found"
    exit 1
fi

LATEST_DIR_NAME=$(basename "$LATEST_DIR")
echo "Latest backup folder: $LATEST_DIR_NAME"

# ====== finding enc file ======
LATEST_ZIP=$(ssh ${RASPBERRY_PI_USER}@${RASPBERRY_PI_IP} \
    "ls -1t ${LATEST_DIR}/*.enc 2>/dev/null | head -n 1")

if [ -z "$LATEST_ZIP" ]; then
    echo "could'nt find .enc file in: $LATEST_DIR"
    exit 1
fi

LATEST_ENC_NAME=$(basename "$LATEST_ZIP")
echo "Newest enc file: $LATEST_ENC_NAME"

# ====== downloading enc file ======
echo "downloading enc file"
rsync -avz --progress \
    "${RASPBERRY_PI_USER}@${RASPBERRY_PI_IP}:${LATEST_DIR}/${LATEST_ENC_NAME}" \
    "$LOCAL_DESKTOP_DIR/"

echo "downloaded backup: $LOCAL_DESKTOP_DIR/$LATEST_ENC_NAME"
