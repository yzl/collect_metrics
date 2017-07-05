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
