if node.name == 'controller1'
  ['mariadb', 'mariadb-server', 'python2-PyMySQL'].each do |pkg|
    package pkg do
      action :install
    end
  end

  template '/etc/my.cnf.d/openstack.cnf' do
    source 'openstackcnf.erb'
    owner 'root'
    group 'root'
    mode '0644'
  end

  service 'mariadb' do
    action [:enable, :start]
    subscribes :restart, 'template[/etc/my.cnf.d/openstack.cnf]'
    action :nothing
  end
end
