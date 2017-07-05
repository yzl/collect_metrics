#!/bin/bash

source /home/centos/instance_info

hostname=`hostname`

es_5_minute_json='{"size":0,"aggs":{"last_5_mins":{"filter":{"range":{"hitTime":{"gte":"now-5m","lte":"now"}}},"aggs":{"tps":{"date_histogram":{"field":"hitTime","interval":"second"}}}}}}'

node_index=`curl -s -XGET http://$hostname:9200/_cat/indices | grep 'insights-20' | sort -r | head -1 | awk '{ print $3 }'`
compliance_index=`curl -s -XGET http://$hostname:9200/_cat/indices | grep 'compliance-20' | sort -r | head -1 | awk '{ print $3 }'`

node_records=`curl -s -XGET http://$hostname:9200/$node_index/_count -d $es_5_minute_json | /home/centos/jq-linux64 '.count'`
compliance_records=`curl -s -XGET http://$hostname:9200/$compliance_index/_count -d $es_5_minute_json | /home/centos/jq-linux64 '.count'`
total_records=$(awk "BEGIN {print $node_records+$compliance_records; exit}")

es_metrics[0]=$node_records
es_metrics[1]=$compliance_records
es_metrics[2]=$total_records

 echo "5_minute_insights_records: ${es_metrics[0]}"
 echo "5_minute_compliance_records: ${es_metrics[1]}"
 echo "5_minute_total_records: ${es_metrics[2]}"

per_host_options="--namespace AWS/EC2 --region us-west-2 --dimensions TestId=$test_id,Instance=$instance"

aws cloudwatch put-metric-data $per_host_options --metric-name 5MinuteInsightsRecords --unit Bytes --value ${es_metrics[0]}
aws cloudwatch put-metric-data $per_host_options --metric-name 5MinuteComplianceRecords --unit Percent --value ${es_metrics[1]}
aws cloudwatch put-metric-data $per_host_options --metric-name 5MinuteTotalRecords --unit Count --value ${es_metrics[2]}