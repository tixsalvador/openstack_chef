nodeipaddress = node['ipaddress']
nodehostname = node['hostname']

if node.name == 'controller1'
  package 'rabbitmq-server' do
    action :install
  end

  ruby_block 'Add controller hostname to hosts file' do
    block do
      file = Chef::Util::FileEdit.new('/etc/hosts')
      file.insert_line_if_no_match("#{nodeipaddress}  #{nodehostname}", "#{nodeipaddress}  #{nodehostname}")
      file.write_file
    end
  end
   
  service 'rabbitmq-server' do
    action [:enable, :start] 
  end

  file '/var/tmp/messaging_recipe.lock' do
    action :create_if_missing
    notifies :run, 'execute[openstack-user]', :immediately
  end

  execute 'openstack-user' do
    command '/sbin/rabbitmqctl add_user openstack test123 && /sbin/rabbitmqctl set_permissions openstack ".*" ".*" ".*"'
    action :nothing
  end

end
