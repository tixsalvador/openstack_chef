if node.name == 'controller1'
  template '/root/.my.cnf' do
    source 'mycnf.erb'
    owner 'root'
    group 'root'
    mode '0600'
  end

  execute 'set mysql root pass' do
    command '/bin/mysqladmin -u root password test123'
    user 'root'
    not_if { File.exist?('/root/dbsecured_confirmed') }
  end
  
  execute 'remove anonymous users' do
    command 'mysql -ne "DELETE FROM mysql.user WHERE User=\'\'"'
    user 'root'
    not_if { File.exist?('/root/dbsecured_confirmed') }
  end
   
  execute 'Disallow root login remotely' do
    command 'mysql -ne "DELETE FROM mysql.user WHERE User=\'root\' AND Host NOT IN (\'localhost\', \'127.0.0.1\',\'::1\')"'
    user 'root'
    not_if { File.exist?('/root/dbsecured_confirmed') }
  end

  execute 'Remove test database' do
    command 'mysql -ne "DROP DATABASE test"'
    user 'root'
    not_if { File.exist?('/root/dbsecured_confirmed') }
  ignore_failure true
  end

  execute 'Remove access from test database' do
    command 'mysql -ne "DELETE FROM mysql.db WHERE Db=\'test\' OR Db=\'test\\_%\'"'
    user 'root'
    not_if { File.exist?('/root/dbsecured_confirmed') }
  ignore_failure true
  end

  execute 'Flush table' do
    command 'mysql -ne "FLUSH PRIVILEGES"'
    user 'root'
    not_if { File.exist?('/root/dbsecured_confirmed') } 
  end

  file '/root/dbsecured_confirmed' do
    action :create_if_missing
    owner 'root'
    mode '0644'
  end

end 
