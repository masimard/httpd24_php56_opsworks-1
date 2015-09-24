#
# Cookbook Name:: deploy
# Recipe:: laravel5-deploy
#

node[:deploy].each do |app_name, deploy|

  execute "composer" do
    command <<-EOH
      composer install -d #{deploy[:deploy_to]}/current
    EOH
  end

  file "#{deploy[:deploy_to]}/current/.env" do
    lazy {
      from = "#{deploy[:deploy_to]}/current/.env.example"
      edit = Chef::Util::FileEdit.new(from)
      edit.search_file_replace_line(/^APP_ENV=.*$/, "APP_ENV=#{deploy[:laravel5_deploy][:app_env]}")
      edit.search_file_replace_line(/^APP_DEBUG=.*$/, "APP_DEBUG=#{deploy[:laravel5_deploy][:app_debug]}")
      content edit.send(:contents).lines.join
    }
  end

  directory "#{deploy[:deploy_to]}/current/storage" do
    group deploy[:group]
    owner deploy[:user]
    mode 0777
    action :create
    recursive true
  end

  directory "#{deploy[:deploy_to]}/current/bootstrap/cache" do
    group deploy[:group]
    owner deploy[:user]
    mode 0777
    action :create
    recursive true
  end

  execute "artisan migrate" do
    command <<-EOH
      php #{deploy[:deploy_to]}/current/artisan migrate
    EOH
  end

end
