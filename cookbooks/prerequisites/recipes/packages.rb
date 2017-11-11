package 'chrony' do
  package_name 'chrony'
  action :install
end

ruby_block "edit chrony" do
  block do
    file = Chef::Util::FileEdit.new("/etc/chrony.conf")
    file.insert_line_after_match('^.*?allow\s\d{1,3}\.\d{1,3}.*$', 'allow 10.0.0.0/24') 
    file.write_file
  end
  not_if "cat /etc/chrony.conf | grep 10.0.0.0/24"
end

service 'chronyd' do
  subscribes :restart, "ruby_block[edit chrony]"
end
