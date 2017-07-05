#
# Cookbook:: collect_metrics
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

cookbook_file '/home/centos/instance_data.sh' do
  source 'instance_data.sh'
  user   'centos'
  group  'centos'
  mode   '0755'
  notifies :run, 'execute[populate-instance-info]', :immediately 
end

execute 'populate-instance-info' do
  command '/home/centos/instance_data.sh'
  action :nothing
end

package %w( unzip perl-Switch perl-DateTime perl-Sys-Syslog perl-LWP-Protocol-https perl-Digest-SHA )

directory '/opt/cloudwatch_monitoring'

remote_file '/opt/cloudwatch_monitoring/CloudWatchMonitoringScripts-1.2.1.zip' do
  source 'http://aws-cloudwatch.s3.amazonaws.com/downloads/CloudWatchMonitoringScripts-1.2.1.zip'
  mode '0755'
  notifies :run, 'execute[setup_cloudwatch_scripts]', :immediately
end

execute 'setup_cloudwatch_scripts' do
  cwd '/opt/cloudwatch_monitoring'
  user 'root'
  command <<-EOH
    unzip CloudWatchMonitoringScripts-1.2.1.zip
    crontab -l | { cat; echo "*/5 * * * * /opt/cloudwatch_monitoring/aws-scripts-mon/mon-put-instance-data.pl --mem-util --disk-space-util --disk-path=/ --from-cron"; } | crontab -
  EOH
  action :nothing
end
