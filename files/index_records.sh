#!/bin/bash
source /home/centos/instance_info

hostname=`hostname`

node_indices=`curl -s -XGET http://$hostname:9200/_cat/indices | grep 'insights-20' | awk '{print $3}'`
compliance_indices=`curl -s -XGET http://$hostname:9200/_cat/indices | grep 'compliance-20' | awk '{print $3}'`

if [ -z "$node_indices" ]
then
  echo "no insights index found"
  exit 1
fi

if [ -z "$node_indices" ]
then
  echo "no compliance index found"
  exit 1
fi

node_records=0
compliance_records=0

for index in $( echo $node_indices | awk '{split($0,a,/\s/)} END { for (key in a) { print a[key] } }' ); do
  node_records=$(awk "BEGIN {print `curl -s -XGET http://$hostname:9200/$index/_count | /home/centos/jq-linux64 '.count'`+$node_records; exit}")
done

for index in $(echo $compliance_indices | awk '{split($0,a,/\s/)} END { for (key in a) { print a[key] } }'); do
  compliance_records=$(awk "BEGIN {print `curl -s -XGET http://$hostname:9200/$index/_count | /home/centos/jq-linux64 '.count'`+$compliance_records; exit}")
done

total_records=$(awk "BEGIN {print $node_records+$compliance_records; exit}")

node_index_bytes=0
compliance_index_bytes=0

for index in $( echo $node_indices | awk '{split($0,a,/\s/)} END { for (key in a) { print a[key] } }' ); do
  node_index_bytes=$(awk "BEGIN {print `curl -s -XGET http://$hostname:9200/$index/_stats/store?pretty | /home/centos/jq-linux64 '._all.total.store.size_in_bytes'`+$node_index_bytes; exit}")
done

for index in $(echo $compliance_indices | awk '{split($0,a,/\s/)} END { for (key in a) { print a[key] } }'); do
  compliance_index_bytes=$(awk "BEGIN {print `curl -s -XGET http://$hostname:9200/$index/_stats/store?pretty | /home/centos/jq-linux64 '._all.total.store.size_in_bytes'`+$compliance_index_bytes; exit}")
done

total_bytes=$(awk "BEGIN {print $node_index_bytes+$compliance_index_bytes; exit}")

curtime=`date +%s`
node_index="insights"
compliance_index="compliance"
node_records_per_minute=`/home/centos/index_records.py $node_index $curtime $node_records`
compliance_records_per_minute=`/home/centos/index_records.py $compliance_index $curtime $compliance_records`
total_records_per_minute=$(awk "BEGIN {print $node_records_per_minute+$compliance_records_per_minute; exit}")

node_records_per_minute_int=`echo $node_records_per_minute | awk '{split($0,a,/\./)} END {print a[1]}'`
compliance_records_per_minute_int=`echo $compliance_records_per_minute | awk '{split($0,a,/\./)} END {print a[1]}'`
total_records_per_minute_int=`echo $total_records_per_minute | awk '{split($0,a,/\./)} END {print a[1]}'`

if [ $node_records_per_minute_int -lt 0 ]; then
  $node_records_per_minute=0
fi

if [ $compliance_records_per_minute_int -lt 0 ]; then
  $compliance_records_per_minute=0
fi

if [ $total_records_per_minute_int -lt 0 ]; then
  $total_records_per_minute=0
fi

es_metrics[0]=$node_records
es_metrics[1]=$node_index_bytes
es_metrics[2]=$node_records_per_minute
es_metrics[3]=$compliance_records
es_metrics[4]=$compliance_index_bytes
es_metrics[5]=$compliance_records_per_minute
es_metrics[6]=$total_records
es_metrics[7]=$total_records_per_minute
es_metrics[8]=$total_bytes

per_host_options="--namespace AWS/EC2 --region us-west-2 --dimensions TestId=$test_id,Instance=$instance"

aws cloudwatch put-metric-data $per_host_options --metric-name NodeRecords --unit Count --value ${es_metrics[0]}
aws cloudwatch put-metric-data $per_host_options --metric-name NodeIndexBytes --unit Bytes --value ${es_metrics[1]}
aws cloudwatch put-metric-data $per_host_options --metric-name NodeRecordsPerMinute --unit Count --value ${es_metrics[2]}
aws cloudwatch put-metric-data $per_host_options --metric-name ComplianceRecords --unit Count --value ${es_metrics[3]}
aws cloudwatch put-metric-data $per_host_options --metric-name ComplianceIndexBytes --unit Bytes --value ${es_metrics[4]}
aws cloudwatch put-metric-data $per_host_options --metric-name ComplianceRecordsPerMinute --unit Count --value ${es_metrics[5]}
aws cloudwatch put-metric-data $per_host_options --metric-name TotalRecords --unit Count --value ${es_metrics[6]}
aws cloudwatch put-metric-data $per_host_options --metric-name TotalRecordsPerMinute --unit Count --value ${es_metrics[7]}
aws cloudwatch put-metric-data $per_host_options --metric-name TotalBytes --unit Bytes --value ${es_metrics[8]}