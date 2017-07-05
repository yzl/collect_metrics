include_recipe 'collect_metrics::default'

cookbook_file '/home/centos/data_collector_queue_length.sh' do
 source 'data_collector_queue_length.sh'
 user 'centos'
 mode '755' 
 action :create
end

cron 'data_collector_queue_length' do
  minute '*'
  hour '*'
  weekday '*'
  month '*'
  user 'root'
  command '/home/centos/data_collector_queue_length.sh' 
end
