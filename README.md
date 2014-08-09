Disdtant Heart
==============

### bash commands

Pull data from EC2


     ssh ys 'cat /home/ubuntu/yulias_necklaces/data.log' | sed -E 's/^([^ ]+) \{/\{"timestamp": "\1", /'


Convert json to csv:


    echo 'timestamp,text,date,username,link,agenturl,bmp,delta_seconds,imp_id,start_date,start_timestamp,wifi_BSSID,wifi_signal_strenght,r,g,b'
    cat - | jq -c "[.timestamp,.text,.date,.username,.link,.agenturl,.bmp,.delta_seconds,.imp_id,.start_date,.start_timestamp,.wifi_BSSID,.wifi_signal_strenght,.rgb]" | sed -E 's/\[|\]//g'


