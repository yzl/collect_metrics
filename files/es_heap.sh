#!/bin/bash

source /home/centos/instance_info

hostname=`hostname`

command=`curl -s -XGET "http://$hostname:9200/_nodes/stats/jvm" | /home/centos/jq-linux64 '(.. | .jvm?.mem.heap_used_in_bytes | numbers ) , (.. | .jvm?.mem.heap_used_percent | numbers ) , (.. | .jvm?.gc.collectors.old.collection_count | numbers ) , (.. | .jvm?.gc.collectors.old.collection_time_in_millis | numbers ) , (.. | .jvm?.gc.collectors.young.collection_count | numbers ) , (.. | .jvm?.gc.collectors.young.collection_time_in_millis | numbers )'`

mapfile -t es_metrics <<<"$command"

# echo "heap_used_in_bytes: ${es_metrics[0]}"
# echo "heap_used_percent: ${es_metrics[1]}"
# echo "gc_old_collection_count: ${es_metrics[2]}"
# echo "gc_old_collection_time_in_millis: ${es_metrics[3]}"
# echo "gc_young_collection_count: ${es_metrics[4]}"
# echo "gc_young_collection_time_in_millis: ${es_metrics[5]}"

per_host_options="--namespace AWS/EC2 --region us-west-2 --dimensions TestId=$test_id,Instance=$instance"

aws cloudwatch put-metric-data $per_host_options --metric-name HeapUsedInBytes --unit Bytes --value ${es_metrics[0]}
aws cloudwatch put-metric-data $per_host_options --metric-name HeapUsedPercent --unit Percent --value ${es_metrics[1]}
aws cloudwatch put-metric-data $per_host_options --metric-name GCOldCollectionCount --unit Count --value ${es_metrics[2]}
aws cloudwatch put-metric-data $per_host_options --metric-name GCOldCollectionTimeInMillis --unit Milliseconds --value ${es_metrics[3]}
aws cloudwatch put-metric-data $per_host_options --metric-name GCYoungCollectionCount --unit Count --value ${es_metrics[4]}
aws cloudwatch put-metric-data $per_host_options --metric-name GCYoungCollectionTimeInMillis --unit Milliseconds --value ${es_metrics[5]}
