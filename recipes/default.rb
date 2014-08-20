include_recipe "build-essential"

nanomsg_version = node[:nanomsg][:version]
nanomsg_tar_gz = File.join(
  Chef::Config[:file_cache_path],
  "/",
  "nanomsg-#{nanomsg_version}.tar.gz")
download_url = node[:nanomsg][:download_url] % {:version => nanomsg_version}
install_dir = node[:nanomsg][:install_dir] % {:version  => nanomsg_version}

remote_file nanomsg_tar_gz do
  source download_url
end

bash "install nanomsg #{nanomsg_version}" do
  cwd Chef::Config[:file_cache_path]
  code <<-EOH
    tar xzf #{nanomsg_tar_gz}
    cd nanomsg-#{nanomsg_version} && ./configure --prefix=#{install_dir} && make && make install
    echo -e "/opt/nanomsg-#{nanomsg_version}/lib\\n" > /etc/ld.so.conf.d/nanomsg-#{nanomsg_version}.conf
    ldconfig
  EOH
  not_if { ::FileTest.exists?("#{install_dir}/lib/libnanomsg.so") }
end
