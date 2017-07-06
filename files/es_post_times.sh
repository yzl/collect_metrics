#!/bin/bash

source /home/centos/instance_info

# This script is intended to run every 5 minutes from cron.
# It will produce average request time and average upstream response time over 5-minute intervals. 

# from /var/opt/delivery/nginx/etc/nginx.conf 
# log_format opscode '$remote_addr - $remote_user [$time_local]  '
#                    '"$request" $status "$request_time" $body_bytes_sent '
#                    '"$http_referer" "$http_user_agent" "$upstream_addr" "$upstream_status" "$upstream_response_time" "$http_x_chef_version"

command=`grep bulk /var/log/delivery/nginx/es_proxy.access.log | grep POST | awk '{gsub(/"/, "")} {sum10+=$10; sum17+=$17} END {print sum10/NR "\n" sum17/NR}'`
mapfile -t es_response_time <<<"$command"

# echo "request_time: ${es_response_time[0]}"
# echo "upstream_response_time: ${es_response_time[1]}"

per_host_options="--namespace AWS/EC2 --region us-west-2 --dimensions TestId=$test_id,Instance=$instance"

aws cloudwatch put-metric-data $per_host_options --metric-name 5MinuteAveragePostRequestTime --unit Bytes --value ${es_response_time[0]}
aws cloudwatch put-metric-data $per_host_options --metric-name 5MinuteAveragePostUpstreamResponseTime --unit Bytes --value ${es_response_time[1]}

# zero out the log file
echo '' > /var/log/delivery/nginx/es_proxy.access.log
