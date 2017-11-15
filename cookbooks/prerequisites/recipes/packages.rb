package 'chrony' do
  package_name 'chrony'
  action :install
end

package 'centos-release-openstack-pike' do
  package_name 'centos-release-openstack-pike'
  action :install
end

execute 'yum-update-all' do
  command 'yum -y upgrade'
  subscribes :run, 'package[centos-release-openstack-pike]', :immediately
  action :nothing
end

['python-openstackclient', 'openstack-selinux'].each do |pkg|
  package pkg do
    action :install
  end
end

if node['hostname'] == 'controller'
  ruby_block 'edit controller chrony' do
    block do
      file = Chef::Util::FileEdit.new('/etc/chrony.conf')
      file.insert_line_after_match('^.*?allow\s\d{1,3}\.\d{1,3}.*$', 'allow 10.0.0.0/24')
      file.write_file
    end # block
    not_if 'cat /etc/chrony.conf | grep 10.0.0.0/24'
  end # ruby_block

  service 'chronyd' do
    subscribes :restart, 'ruby_block[edit controller chrony]'
  end # service chronyd
end # if node

if node['hostname'] != 'controller'
  ruby_block 'add controller as ntp server on other nodes' do
    block do
      file = Chef::Util::FileEdit.new('/etc/chrony.conf')
      file.insert_line_after_match('^.*?Please\sconsider\sjoining\s.*$', 'server controller iburst')
      file.search_file_delete('^.*?server\s\d\.\w+\.pool.*?\siburst.*$')
      file.write_file
    end
    not_if "egrep '^server\scontroller\siburst' /etc/chrony.conf"
  end

  service 'chronyd' do
    subscribes :restart, 'ruby_block[add controller as ntp server on other nodes]'
  end
end
