ruby_block 'host_file' do
  block do
    file = Chef::Util::FileEdit.new('/etc/hosts')
    file.insert_line_if_no_match('#BEGIN HOSTFILE', '#BEGIN HOSTFILE')
    file.insert_line_if_no_match('10.0.0.11   controller', '10.0.0.11   controller')
    file.insert_line_if_no_match('10.0.0.31   compute', '10.0.0.31   compute')
    file.insert_line_if_no_match('10.0.0.41   block', '10.0.0.41   block')
    file.insert_line_if_no_match('10.0.0.51   object1', '10.0.0.51   object1')
    file.insert_line_if_no_match('10.0.0.52   object2', '10.0.0.52   object2')
    file.insert_line_if_no_match('10.0.0.61   controlmanager', '10.0.0.61   controlmanager')
    file.insert_line_if_no_match('#END HOSTFILE', '#END HOSTFILE')
    file.write_file
  end
end

package 'firewalld' do
  action :install
end

service 'firewalld' do
  action [:enable, :start]
end

execute 'enable_all_ports_on_localnet' do
  command '/bin/firewall-cmd --zone=public --permanent --add-rich-rule="rule family="ipv4" source address="10.0.0.0/24" accept"'
  not_if '/bin/firewall-cmd --list-rich-rule | grep 10.0.0.0'
end

if node.name == 'controller1'
  execute 'allow mysql connection' do
    command '/bin/firewall-cmd --add-service=mysql'
    not_if '/bin/firewall-cmd --list-services | grep mysql'
  end
end 

service 'firewalld' do
  subscribes :reload, 'execute[enable_all_ports_on_localnet]'
end
