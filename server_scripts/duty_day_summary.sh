#!/usr/bin/env bash

#deactivated
#exit 0
period=`date +"%Y%m%d"`
co=""
server_list="https://extranet.who.int/dhis2-dev https://extranet.who.int/dhis2-cont-dev https://extranet.who.int/dhis2 https://extranet.who.int/dhis2-demo https://portal-uat.who.int/dhis2 https://portal-uat.who.int/dhis2-cont"

for url in $server_list; do
if [ $url == 'https://extranet.who.int/dhis2-dev' ];then
	co="YkqDSFqJw7G"
elif [ $url == 'https://extranet.who.int/dhis2-cont-dev' ];then
        co="JhrMD8OMFyf"
elif [ $url == 'https://extranet.who.int/dhis2' ];then
        co="hHIs5QYHbQP"
elif [ $url == 'https://extranet.who.int/dhis2-demo' ];then
        co="qpRs0fsxSeB"
elif [ $url == 'https://portal-uat.who.int/dhis2' ];then
        co="irkK9eyChrC"
elif [ $url == 'https://portal-uat.who.int/dhis2-cont' ];then
        co="jXGgFnnjHAW"
else
	echo "Wrong url"
	exit 0
fi

check_exit(){
    if [ $? -eq 0 ]; then
        echo OK
    else
        echo FAIL
	exit 0
    fi
}

#Get public objects count by metadata type
echo "requesting public objects count by metadata from $url"
source ~/.dhis2_info_credentials
result=$(curl --user ${dhis2_user_credentials} $url'/api/sqlViews/sNvGgFza3YR/data' -X GET -H 'Content-Type: application/json' | jq '.listGrid' | jq '.rows' | jq .)
check_exit

#Format result
result=${result:1:-1}
result=${result//[/\{}
result=${result//]/\}}
result=${result//\",/\":}
result="["$result"]"
echo $result

#get count of total public objects
echo "requesting total of public objects from $url"
total_count=$(curl --user ${dhis2_user_credentials} $url'/api/sqlViews/RIw9kc7N4g4/data' -X GET -H 'Content-Type: application/json' | jq '.pager' | jq '.total')
check_exit
echo $total_count


echo "sending public objects count by metadata"
query="de=HF0iZZ0NqDE&co=$co&ds=FnYgTt843G2&ou=H8RixfF8ugH&pe=$period&value=$total_count"
echo $(curl -u ${dhis2_user_credentials}  'https://extranet.who.int/dhis2-dev/api/dataValues' -H 'Accept: */*' -H 'Content-Type: application/x-www-form-urlencoded' -X POST --data $query --compressed )
check_exit

query="de=ulfI0WDmW92&co=$co&ds=FnYgTt843G2&ou=H8RixfF8ugH&pe=$period&value=$result"
echo "sending total public objects"
echo $(curl -u ${dhis2_user_credentials} 'https://extranet.who.int/dhis2-dev/api/dataValues' -H 'Accept: */*' -H 'Content-Type: application/x-www-form-urlencoded' -X POST --data "$query" --compressed)

check_exit
done
echo "Done"

