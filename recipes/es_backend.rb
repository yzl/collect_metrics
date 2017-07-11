include_recipe 'collect_metrics::default'

cookbook_file '/home/centos/es_heap.sh' do
 source 'es_heap.sh'
 user 'centos'
 mode '755' 
 action :create
end

cron 'es_heap' do
  minute '*'
  hour '*'
  weekday '*'
  month '*'
  user 'centos'
  home '/home/centos'
  command '/home/centos/es_heap.sh' 
end

cookbook_file '/home/centos/disk_queue_size.sh' do
 source 'disk_queue_size.sh'
 user 'centos'
 mode '755'
 action :create
end

cron 'disk_queue_size' do
  minute '*'
  hour '*'
  weekday '*'
  month '*'
  user 'centos'
  home '/home/centos'
  command '/home/centos/disk_queue_size.sh'
end

cookbook_file '/home/centos/index_records.sh' do
 source 'index_records.sh'
 user 'centos'
 mode '755'
 action :create
end

cookbook_file '/home/centos/index_records.py' do
 source 'index_records.py'
 user 'centos'
 mode '755'
 action :create
end

cron 'index_records' do
  minute '*/5'
  hour '*'
  weekday '*'
  month '*'
  user 'centos'
  home '/home/centos'
  command '/home/centos/index_records.sh'
end

cookbook_file '/home/centos/cluster_health.sh' do
 source 'cluster_health.sh'
 user 'centos'
 mode '755'
 action :create
end

cron 'cluster_health' do
  minute '*/5'
  hour '*'
  weekday '*'
  month '*'
  user 'centos'
  home '/home/centos'
  command '/home/centos/cluster_health.sh'
end
