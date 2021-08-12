#!/bin/bash
#set -x

PATH=/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/usr/local/bin:/home/tomcatuser/.local/bin:/home/tomcatuser/bin

export http_proxy=http://openproxy.who.int:8080/
export https_proxy=http://openproxy.who.int:8080/

check_status_exit(){
    if [ $? -eq 0 ]; then
        echo OK
    else
        echo FAIL
        exit 1
    fi
}

rm "$temp_folder"db -r
mkdir "$temp_folder"db

timestamp=$(date +%Y-%m-%d_%H%M)
echo "[${timestamp}] Generating backup into ${backup_file}..."
pg_dump -d "postgresql://${db_user}:${db_pass}@${db_server}:5432/${db_name}" --no-owner --exclude-table 'aggregated*' --exclude-table 'analytics*'  --exclude-table 'completeness*' --exclude-schema sys -Fc -f ${dump_dest_path}/${backup_file}
check_status_exit

mv /home/tomcatuser/backups/"$backup_file" "$temp_folder"db/"$backup_file"

#cp /services/tomcats/preprod-cont/webapps/dhis2-cont.war "$temp_folder"db/dhis2.war

d2-docker stop ${instance_name}

#Create core
#d2-docker create core widp/dhis2-core:2.34 --war="$temp_folder"db/dhis2.war
#check_status_exit

#Create docker
d2-docker create data ${instance_name} --sql="$temp_folder"db/"$backup_file" --apps-dir="$apps_folder" --documents-dir="$document_folder"
check_status_exit

# Remove temp files after docker was created
rm "$temp_folder"db/"$backup_file"

#Start docker
d2-docker start ${instance_name} --port=8085 --detach
check_status_exit

#wait for server
n=0
max=10
delay=100
while true;do
   if [[ $n -lt $max ]]; then
        ((n++))
        echo "Waiting for docker startup. Attempt $n/$max:"
        sleep $delay;
        d2-docker logs ${instance_name} > $log_startup_file
        log=$(cat $log_startup_file | grep "org.apache.catalina.startup.Catalina.start Server startup")
        echo $log
        echo ${#log}
        if [ ${#log} -ge 57 ] ;then
                echo "startup finish"
                echo $log
                break
        else
                echo "starting..."
        fi
   else
        echo "exiting the program due to number of attempts has reached the limit."
        exit 1
   fi
done

echo "update db"
d2-docker run-sql -i ${instance_name} /home/tomcatuser/cloner/d2-docker_sql_scripts/removepasswords.sql
d2-docker run-sql -i ${instance_name}  /home/tomcatuser/cloner/d2-docker_sql_scripts/updateroles.sql

#commit docker
echo "commting docker"
d2-docker commit ${instance_name}
check_status_exit

#push docker
echo "pushing docker"
d2-docker push ${instance_name}
check_status_exit

echo "stopping docker"
d2-docker stop ${instance_name}
check_status_exit

#Clean dockers
echo "clean dockers"
d2-docker rm ${instance_name}
docker rmi $(docker images -f "dangling=true" -q) >> /home/tomcatuser/backups/logs/clean_docker.log 2>&1
check_status_exit
yes | docker volume prune >> /home/tomcatuser/backups/logs/clean_docker_volume.log 2>&1

