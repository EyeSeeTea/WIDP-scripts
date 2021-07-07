# INSTRUCCIONES PARA INSTALAR POSTGRES EN WIDP
# Comandos de shell y de SQL
#


# checks de versiones y resultado en otra instalación
dhishq_preprod=> SELECT version();
                                                 version
----------------------------------------------------------------------------------------------------------
 PostgreSQL 10.10 on x86_64-pc-linux-gnu, compiled by gcc (GCC) 4.8.5 20150623 (Red Hat 4.8.5-36), 64-bit

dhishq_preprod=> SELECT PostGIS_Version();
            postgis_version
---------------------------------------
 2.5 USE_GEOS=1 USE_PROJ=1 USE_STATS=1


# instalacion de los paquetes
yum list postgresql10.x86_64 --showduplicates

##sudo yum remove postgresql10-libs
sudo yum install postgresql10-10.10-1PGDG.rhel7
sudo yum install postgresql10-server-10.10-1PGDG.rhel7

sudo rpm -Uvh pgdg-redhat-repo-latest.noarch.rpm
 Preparing...                          ################################# [100%]
Updating / installing...
   1:pgdg-redhat-repo-42.0-9          ################################# [ 50%]
Cleaning up / removing...
   2:pgdg-redhat-repo-42.0-4          ################################# [100%]



#dhisuser@preprod-new:~$ sudo systemctl enable postgresql-10
#Created symlink from /etc/systemd/system/multi-user.target.wants/postgresql-10.service to /usr/lib/systemd/system/postgresql-10.service.

# instalar dependencias de postgis25_10 manualmente
wget https://yum.postgresql.org/9.6/redhat/rhel-7-x86_64/sqlite33-3.30.1-1.rhel7.x86_64.rpm
wget https://download.postgresql.org/pub/repos/yum/10/redhat/rhel-7-x86_64/sqlite33-libs-3.30.1-1.rhel7.x86_64.rpm
sudo rpm -i sqlite33-libs-3.30.1-1.rhel7.x86_64.rpm
sudo rpm -i sqlite33-3.30.1-1.rhel7.x86_64.rpm

sudo yum install postgis25_10

# como alguna de estas instalaciones actualiza el python
# desde el usuario dhisuser, seleccionar 3.4
sudo alternatives --config python3


sudo /usr/pgsql-10/bin/postgresql-10-setup initdb

# cambiar al directorio de postgres
cd /var/lib/pgsql/10/
# para inicializar la BD
rm -R data/*
/usr/pgsql-10/bin/initdb -D '/var/lib/pgsql/10/data'
/usr/pgsql-10/bin/pg_ctl -D /var/lib/pgsql/10/data -l logfile start

# from postgres
# solo si no existe
CREATE USER dhishq_usr;
# crear la BD con el propietario correcto
DROP DATABASE dhishq;
CREATE DATABASE dhishq OWNER = dhishq_usr ;
# importante hacer el GRANT antes de crear la extension postgis
GRANT all privileges on database dhishq to dhishq_usr;
# crear la extension dentro de la BD
CREATE EXTENSION postgis;

# change postgresql data directory
# from postgres
 /usr/pgsql-10/bin/pg_ctl -D /var/lib/pgsql/10/data stop

# from dhisuser
sudo mkdir /services/pgsql
sudo mv /var/lib/pgsql/ /var/lib/pgsql_delete
sudo ln -s /services/pgsql/ /var/lib/
sudo chown -h postgres:postgres /var/lib/pgsql
sudo chown -h postgres:postgres /services/pgsql/
sudo vi /etc/passwd # change psotgres home director to /services/pgsql

# from postgres
cp -R /var/lib/pgsql_delete/* /services/pgsql/


# from dhisuser
sudo rm -R /var/lib/pgsql_delete/

# from postgres
/usr/pgsql-10/bin/pg_ctl -D /var/lib/pgsql/10/data -l logfile start #? test with symlink

# from tomcatuser 
# backup database 
 /home/tomcatuser/bin/backup_db_prod.sh
 cd 
 cd backups
 pg_restore -h localhost -d dhishq -Fc -U dhishq_usr -W BACKUP-PROD-MANUAL-2020-04-24_1703_cformat.dump 
 pg_restore -h localhost -d dhishq_cont -Fc -U dhishq_usr -W BACKUP-PROD-MANUAL-2020-04-24_1703_cformat.dump 
# upgrade 2.34
 pg_restore -h localhost -d dhishq -Fc -U dhishq_usr -W BACKUP-PROD-pre_2.34_upgrade_cformat.dump
 
 
 
 
 
 SELECT e.extname , n.nspname      AS home_schema_of_extension, extrelocatable AS extension_can_be_relocated 
 FROM   pg_catalog.pg_extension e
 JOIN   pg_catalog.pg_namespace n ON n.oid = e.extnamespace;

