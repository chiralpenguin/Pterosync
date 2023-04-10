# Pterosync 1.0 by chiralpenguin
# Automated backup script for Pterodactyl servers using rsync iterative backups
# This script is intended to automate backups from a remote server via SSH by
# running the script from cron on the backup server.

# Define connection information - username, password, address and SSH port of
# remote host
# If password="", key authentication will be used. You SHOULD avoid password-
# based authentication (not even implenented yet)
readonly ADDRESS=127.0.0.1
readonly USERNAME="admin"
readonly PASSWD=""
readonly PORT=22

# Define paths for backup location on the local machine and pterodactyl server
# location on the remote machine
# Credit to Egidio Docile (https://linuxconfig.org/how-to-create-incremental-backups-using-rsync-on-linux)
# for implementation of hard links with rsync
readonly PTERO_DIR="/var/lib/pterodactyl/volumes"
readonly BACKUP_DIR="/home/backupuser/Backups"

declare -A servers

# Define servers with the UUID of the docker container as the ID and the server
# name as the value in the following format
# servers[UUID]="Server Name"
servers[c5a99fd1-b655-47e0-8648-66eb62e73a9e]="My Server"
servers[5a852865-aacf-4225-be26-f09209152c6d]="Another Server"

for id in ${!servers[@]}
do
    echo "Backing up: ${servers[$id]} (UUID: ${id})"
    declare SOURCE_DIR="${PTERO_DIR}/${id}"
    declare DATETIME="$(date '+%Y-%m-%d_%H:%M:%S')"
    declare BACKUP_PATH="${BACKUP_DIR}/${servers[$id]}/${DATETIME}"
    declare LATEST_LINK="${BACKUP_PATH}/../latest"

    mkdir -p "${BACKUP_PATH}"

    rsync -ahzuv --progress \
      -e "ssh -p ${PORT}" \
      "${USERNAME}@${ADDRESS}:${SOURCE_DIR}/" \
      --link-dest "${LATEST_LINK}" \
      "${BACKUP_PATH}"

    rm -rf "${LATEST_LINK}"
    ln -s "${BACKUP_PATH}" "${LATEST_LINK}"
done
