#! /usr/bin/env bash
#
# Author: Marc Garnica Caparros <marcgarnica@eyeseetea.com>
#
#/ Usage: pwd_transfer NEW_USERS_FILE.json SOURCE_TABLE.sql...
#/
#/
#/ ARGUMENTS
#/ NEW_USERS_FILE.json - Metadata file with the new imported users to the instance.
#/ SOURCE_TABLE.sql - SQL file with the sentences to replicate source instance users.
#/
set -o errexit   # abort on nonzero exitstatus
set -o nounset   # abort on unbound variable
set -o pipefail  # don't hide errors within pipes

#GLOBAL VARIABLES
DATABASE="postgresql://dhis:dhis2@localhost:5432/dhis2"
SOURCE_SCHEMA="public"
SOURCE_TABLE="users"
AUX_USERS_SQL="/tmp/aux_users_file.sql"
AUX_SCHEMA="public"
AUX_TABLE="aux_users"

usage() {
  printf "\n"
  printf "Usage: pwd_transfer.sh NEW_USERS_FILE.json SOURCE_TABLE_USERS.sql"
  printf "\n"
  printf "\n"
  printf "NEW_USERS_FILE.json - Metadata file with the new imported users to the instance.\n"
  printf "SOURCE_TABLE_USERS.sql - SQL file with the sentences to replicate source instance users.\n"
  printf "\n"
}

#### MAIN

if [ $# -ne 2 ]; then
  usage
  exit 1
fi

printf "... Starting transfer of passwords ..."

#### PARAMS
USERS_FILE=$1
SOURCE_FILE=$2

printf "Getting new users ids\n"
NEW_IDS=$(jq -r '.users | map("\"" + .userCredentials.id + "\"") | join(", ")' $USERS_FILE | sed "s/\"/'/g")
printf "\n"

printf "Applying aux table\n"
printf "sed 's/$SOURCE_SCHEMA.$SOURCE_TABLE/$AUX_SCHEMA.$AUX_TABLE/g' $SOURCE_FILE > $AUX_USERS_SQL\n"
sed "s/$SOURCE_SCHEMA.$SOURCE_TABLE/$AUX_SCHEMA.$AUX_TABLE/g" $SOURCE_FILE > $AUX_USERS_SQL
psql -d $DATABASE -f $AUX_USERS_SQL
printf "\n"

printf "Updating passwords and deleting temporal entities\n"
sql_update="UPDATE users SET password = $AUX_TABLE.password, secret = $AUX_TABLE.secret FROM $AUX_TABLE WHERE users.uid = $AUX_TABLE.uid AND $AUX_TABLE.uid IN ("$NEW_IDS");"

psql -d $DATABASE -c "$sql_update"
psql -d $DATABASE -c "DROP TABLE $AUX_SCHEMA.$AUX_TABLE;"
printf "\n"

printf "Transfer finished\n"
