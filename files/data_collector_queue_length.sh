#!/bin/bash

source /home/centos/instance_info

command=`PATH=$PATH:/opt/delivery/embedded/bin rabbitmqctl list_queues -p /insights | grep data-collector | awk '{ print $2}'`
per_host_options="--namespace AWS/EC2 --region us-west-2 --dimensions TestId=$test_id,Instance=$instance"

aws cloudwatch put-metric-data $per_host_options --metric-name DataCollectorQueueLength --unit Bytes --value ${command}
