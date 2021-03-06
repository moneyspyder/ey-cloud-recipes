#
# Cookbook Name:: resque
# Recipe:: default
#
if ['solo', 'util', 'app', 'app_master'].include?(node[:instance_role])
  
  execute "install resque gem" do
    command "gem install resque redis redis-namespace yajl-ruby -r"
    not_if { "gem list | grep resque" }
  end

  case node[:ec2][:instance_type]
  when 'm1.small' then worker_count = 2
  when 'c1.medium'then worker_count = 3
  when 'c1.xlarge' then worker_count = 8
  else worker_count = 4
  end

  Chef::Log.info("[resque] Setting up resque for a #{node[:ec2][:instance_type]} instance with #{worker_count} workers")

  node[:applications].each do |app, data|
    if app != 'FlowercardPrinting'
      ey_cloud_report "Running resque script for #{app}" do
        message "Rescue: #{app}" 
      end
      template "/etc/monit.d/resque_#{app}.monitrc" do
        owner 'root' 
        group 'root' 
        mode 0644 
        source "monitrc.conf.erb" 
        variables({ 
        :num_workers => worker_count,
        :app_name => app, 
        :rails_env => node[:environment][:framework_env] 
        }) 
      end

      worker_count.times do |count|
        template "/data/#{app}/shared/config/resque_#{count}.conf" do
          owner node[:owner_name]
          group node[:owner_name]
          mode 0644
          if count == 0
            source "resque_high_to_medium.conf.erb"
          else
            source "resque_wildcard.conf.erb"
          end
        end
      end

      execute "ensure-resque-is-setup-with-monit - #{app}" do 
        epic_fail true
        command %Q{ 
        monit reload 
        } 
      end
    end
  end 
end
