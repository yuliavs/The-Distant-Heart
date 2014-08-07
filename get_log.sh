# ssh ys 'cat /home/ubuntu/yulias_necklaces/data/log.json' | sed -E 's/^[^ ]+ //'
ssh ys 'cat /home/ubuntu/yulias_necklaces/data.log' | sed -E 's/^[^ ]+ //' 
