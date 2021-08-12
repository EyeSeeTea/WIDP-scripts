source ~/.dhis2_info_credentials
baseurl="https://extranet.who.int/"
tei="uY6e8NHVDH2"
enrollment="ubVJxNaIunK"
dataelement_12="iBDyhSHSk1K"
dataelement_00="z0JzzSTL65T"
dataelement_tei_00="euPtt2LWNis"
dataelement_tei_12="X8XLOWOJsbR"
dataelement_event_00="JKmrptCJjQN"
dataelement_event_12="KfhTiPYwKPm"

period=`date +"%Y%m%d"`
day=`date +"%Y-%m-%d"`
hour=`date +"%H"`
echo $hour
if [ $hour -lt 12 ];
then
 dataelement=$dataelement_00
 dataelement_tei=$dataelement_tei_00
 dataelement_event=$dataelement_event_00
else
 dataelement=$dataelement_12
 dataelement_tei=$dataelement_tei_12
 dataelement_event=$dataelement_event_12
fi
dataset="de=$dataelement&co=Xr12mI7VPn3&ds=C47NApwU2kc&ou=H8RixfF8ugH&pe=$period&value=true"
tei="{'events':[{'trackedEntityInstance':'${tei}','program':'rjsnrRKjtwU','programStage':'DQitAUlaicG','enrollment':'${enrollment}','orgUnit':'H8RixfF8ugH','notes':[],'dataValues':[{'dataElement':'${dataelement_tei}','value':'true','providedElsewhere':false}],'status':'ACTIVE','eventDate':'${day}'}]}"
event="{'program':'yx6VLBFBlrK','programStage':'EGA9fqLFtxM','orgUnit':'H8RixfF8ugH','status':'ACTIVE','eventDate':'${day}','dataValues':[{'dataElement':'${dataelement_event}','value':'true'}]}"
tei=${tei//[\']/\"}
event=${event//[\']/\"}
url="${baseurl}${1}"
echo $url
echo $dataset
echo $tei
echo $event
echo "agg"
result=`curl -u ${dhis2_user_credentials} "${url}/api/dataValues"  -H 'Content-Type: application/x-www-form-urlencoded; charset=UTF-8' -H 'Accept: */*'  --data ${dataset} --compressed`
echo $result
echo "event"
result3=`curl "$url/api/30/events.json" -u ${dhis2_user_credentials} -H 'Content-Type: application/json;charset=UTF-8' --data-binary ${event} --compressed`
echo $result3
echo "tei"
result2=`curl "$url/api/30/events.json" -u ${dhis2_user_credentials} -H 'Content-Type: application/json;charset=UTF-8' --data-binary ${tei} --compressed`
echo $result2
echo "finish"

