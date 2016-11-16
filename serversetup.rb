if platform?('ubuntu')

	apt_update 'debian' do
		action :update
	end
	%w{tomcat7 tomcat7-docs tomcat7-admin tomcat7-examples}.each do |pkg|
  		package pkg do
    			action :install
  		end
	end
	template '/etc/tomcat7/tomcat-users.xml' do
		source "tomcat-users.erb"
		variables({
			:username => 'tomcat',
			:password => 'password'
		})
	end	
	service 'tomcat' do
		service_name 'tomcat7'
		action :restart
	end

end
if platform?('redhat') 

        %w{tomcat tomcat-webapps tomcat-admin-webapps tomcat-docs-webapp }.each do |pkg|
                package pkg do
                        action :install
			ignore_failure true
                end
        end
        template '/usr/share/tomcat/conf/tomcat-users.xml' do
                source "tomcat-users.erb"
        end
        service 'tomcat' do
                service_name 'tomcat'
                action :start
        end

end
if platform?('windows') 
	 %w{ IIS-WebServerRole IIS-WebServer NetFx4Extended-ASPNET45 IIS-HttpCompressionDynamic IIS-WebServerManagementTools IIS-ManagementConsole IIS-ApplicationDevelopment IIS-ApplicationInit IIS-ISAPIFilter IIS-ISAPIExtensions IIS-NetFxExtensibility45 IIS-ASPNET45 IIS-ManagementScriptingTools IIS-HttpRedirect }.each do |feature|
                windows_feature feature do
                        action :install
                end
        end
	#directory "#{node['iis']['docroot']}/devopsPortal" do
		#action :create
		#not_if { Dir.exist?("#{node['iis']['docroot']}/devopsPortal") }
	#end 
        #iis_pool 'devopsPortal' do
        #        runtime_version "4.0"
        #        pipeline_mode :Integrated
        #        action :add
        #        pool_identity :NetworkService
        #end
        #iis_site 'Default Web Site' do
         #       action [:stop, :delete]
        #end
        #iis_site 'Default Web Site' do
        #        action :start
        #        protocol :http
        #        port 80
        #        application_pool "devopsPortal"
        #        path "#{node['iis']['docroot']}/devopsPortal"
        #end
	batch 'edit hosts file' do               
		 code <<-EOH
                        echo #{node['sqlserver']}       dbserver >> C:\\Windows\\System32\\drivers\\etc\\hosts
                EOH
        end
	package 'msbuild' do
		source 'https://download.microsoft.com/download/9/B/B/9BB1309E-1A8F-4A47-A6C5-ECF76672A3B3/BuildTools_Full.exe'
		installer_type :custom
		action :install
		options '/S'
	end

end
