#training
#0 3 * * * /home/tomcatuser/bin/backup_db_training.sh DAILY --docker >> /home/tomcatuser/backups/logs/db_backups.log 2>&1
#0 4 * * 0 /home/tomcatuser/bin/backup_db_training.sh WEEKLY --docker >> /home/tomcatuser/backups/logs/db_backups.log 2>&1
#0 5 1 * * /home/tomcatuser/bin/backup_db_training.sh MONTHLY --docker >> /home/tomcatuser/backups/logs/db_backups.log 2>&1
#saved in a folder: BACKUP-TRAINING-DAILY
#script:

#!/bin/sh
#set -x

#Add user local bin to the path to run d2-docker
export PATH=${PATH}:/usr/local/bin

timestamp=$(date +%Y-%m-%d_%H%M)
period=
docker=0

if [ $# -gt 2 ]; then
  echo "wrong parameter number"
  exit 1
elif [ $# -eq 1 -o $# -eq 2 ]; then
  if [ "$1" == "-h" -o "$1" == "--help" ]; then
    echo "USAGE: ./backup_db.sh [PERIOD] [--docker]"
    echo "If no PERIOD is given, then a manual dump is generated with timestamp, otherwise the given period is used in the name of the destination file."
    echo "If the flag --docker is provided, then d2-docker will be used to backup the docker image"
    exit
  elif [ "$1" == "--docker" ]; then
    docker=1
  fi
  period=$1
  if [ $# -eq 2 ]; then
    if [ "$2" == "--docker" ]; then
      docker=1
    fi
  fi
else
  period=MANUAL-${timestamp}
fi

check_status(){
    if [ $? -eq 0 ]; then
        echo OK
    else
        echo FAIL
    fi
}

backup_base=BACKUP-${dhis2_instance}-${period}
backup_file=${backup_base}_cformat.dump
backup_docker_folder=${backup_base}

if [ $docker -eq 0 ]; then
  echo "[${timestamp}] Generating backup into ${backup_file}..."
  pg_dump -d "postgresql://${db_user}:${db_pass}@${db_server}:5432/${db_name}" --no-owner --exclude-table 'aggregated*' --exclude-table 'analytics*' --exclude-table 'completeness*' --exclude-schema sys -Fc -f ${dump_dest_path}/${backup_file}
  check_status
  echo "[${timestamp}] Generated backup: ${backup_file}..."
else
  echo "[${timestamp}] Deleting previous docker image backup folder ${backup_base}"
  rm -rf ${dump_dest_path}/${backup_docker_folder}
  check_status
  echo "[${timestamp}] Saving ${docker_image} docker image status..."
  d2-docker commit ${docker_image}
  check_status
  echo "[${timestamp}] Generating ${docker_image} docker image backup into ${backup_base} folder..."
  check_status
  d2-docker copy ${docker_image} ${dump_dest_path}/${backup_docker_folder}
  check_status
  echo "[${timestamp}] D2-docker backup into ${backup_file}... finish"
fi


