ruby_block "host_file" do
  block do
    file = Chef::Util::FileEdit.new("/etc/hosts")
    file.insert_line_if_no_match("10.0.0.11   controller", "10.0.0.11   controller")
    file.insert_line_if_no_match("10.0.0.31   compute", "10.0.0.31   compute")
    file.insert_line_if_no_match("10.0.0.41   block", "10.0.0.41   block")
    file.insert_line_if_no_match("10.0.0.51   object1", "10.0.0.51   object1")
    file.insert_line_if_no_match("10.0.0.52   object2", "10.0.0.52   object2")
    file.insert_line_if_no_match("10.0.0.61   controlmanager", "10.0.0.61   controlmanager")
    file.write_file
  end
end
