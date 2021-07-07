## Transfer of passwords between DHIS2 production instances
Bash script interacting with SQL sentences to operate a transfer of passwords among two production DHIS2 instances.

The script [pwd_transfer.sh](./pwd_transfer.sh) follows the following workflo

### Requirements
 - Operating system: GNU/Linux.
 - Commands: sed, jq, psql.

### Pre-conditions
The scripts needs to files to correctly execute the transfer:
 - A json file with the users imported in the target DHIS2 instances from the source instance. The files structure must ressemble the DHIS2 users API resource. The script must be able to parse the following structure in the file:
 ```json
 {
   "users": [
     {
       ...,
       "userCredentials": {
         ...,
         "id": "<id_value>",
       }
     }
   ]
 }
 ```

 - A database dump with the source instance user table, preferably with the following command:

 ```bash
 pg_dump -d "<database_connection_url>" --table users -f <result_file>.sql
 ```

### Usage
```bash
pwd_transfer.sh NEW_USERS_FILE.json SOURCE_TABLE_USERS.sql
```

 - *NEW_USERS_FILE.json* - Metadata file with the new imported users to the instance.
 - *SOURCE_TABLE_USERS.sql* - SQL file with the sentence to replicate source instance users.

The script executes the following workflow:
 1. Extracts all the new users ids from the *NEW_USERS_FILE.json* file.
 2. Create and auxiliar users table in the target instance with the information on *SOURCE_TABLE_USERS*.
 3. Updates the password and secret attributes of the target users table for all the users present in the list of new users ids extracted in point 1.
 4. Deletes and clean any auxiliar entity.
