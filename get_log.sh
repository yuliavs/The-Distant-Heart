ssh ys 'cat /home/ubuntu/yulias_necklaces/data.log' | sed -E 's/^([^ ]+) \{/\{"timestamp": "\1", /'
