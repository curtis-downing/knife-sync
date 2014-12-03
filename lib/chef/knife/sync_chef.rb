# quick and easy restore for chef
# this plugin is really about wrapping around knife upload and syncing to multiple chef servers using knife-block
# if opscode ever decices to add features similar to knife-block that supports multiple chef servers
# this would become obsolote and that would be alright by me!

# knife upload does not seem to affect roles likely because of the .rb extension!? - seems like the json files get sent up with "knife upload".... 
# *sigh* thanks opscode for giving us half way there features... I'm with Rob Brown - please add this feature opscode which will probably cover
# the problem I'm having here as well... *wishfully thinking* 
# https://tickets.opscode.com/browse/CHEF-3984

# Why not just use knife-upload? Multiple server support with knife-block and getting it done with one command!
# This supports the force option for knife-upload so use --force if you want to push everything to your flagset
# it only uploades things that need changing whichs speeds things up


require "chef/knife"

module Company
  class SyncChef< Chef::Knife

    deps do
      require 'chef/knife/core/object_loader'
      require 'chef/knife/upload'
      require 'chef/json_compat'
      require 'chef/knife/block'
      require 'net/http'
    end

    banner "knife sync chef (options)"

    option :data_bags,
      :short => "-d",
      :long => "--data-bags",
      :description => "upload all data bags"

    option :roles,
      :short => "-r",
      :long => "--roles",
      :description => "upload all roles"

    option :environments,
      :short => "-e",
      :long => "--environments",
      :description => "upload all environments"

    option :cookbooks,
      :short => "-c",
      :long => "--cookbooks",
      :description => "upload all cookbooks"

    option :all_chefs,
      :short => "-A",
      :long => "--all-chefs",
      :description => "upload to all chef servers defined in 'my_knife_blocks' in you local knife.rb files"

    option :force,
      :short => "-f",
      :long => "--force",
      :boolean => true | false,
      :default => false

    option :all,
      :short => "-a",
      :long => "--all",
      :description => "upload the chef repo (roles, data_bags, cookbooks, environments)",
      :boolean => true | false,
      :default => false

    def run
      self.config = Chef::Config.merge!(config)
      @jenkins_server        = config[:company_jenkins_server]
      @jenkins_trigger_urls  = config[:company_jenkins_sync_triggers]
      @jenkins_trigger_cause = "&cause=#{ENV['USER']}+triggered:+via+knife+sync"
      self.all_chefs
      self.trigger_jenkins
    end

    def force_upload(i)
      if config[:force]
        i.config[:force] = true
      end
    end

    def all_chefs
      # this is really what this plugin is really all about
      if config[:all_chefs]
        knife_block = GreenAndSecure::BlockUse.new
        config[:my_knife_blocks].each do |block|
          knife_block.name_args = [block]
          knife_block.run
          self.configure_chef # reload configs from the changed knife.rb 
          self.do_uploads
        end
      else
        self.do_uploads
      end
    end

    def do_uploads
      if config[:data_bags]
        self.upload_data_bags
      end

      if config[:roles]
        self.upload_roles
      end

      if config[:environments]
        self.upload_environments
      end

      if config[:cookbooks]
        self.upload_cookbooks
      end

      # this is really what this plugin is really all about
      # upload everything in one shot, no more bash scripts and use knife block to many servers
      if config[:all]
        self.upload_data_bags
        self.upload_roles
        self.upload_environments
        self.upload_cookbooks
      end
    end

    def trigger_jenkins
      #only do this if we update data bags 
      if config[:data_bags]
        @jenkins_trigger_urls.each do |trigger_url|
          full_trigger = "#{trigger_url}#{@jenkins_trigger_cause}"
          Net::HTTP.get(@jenkins_server, full_trigger)
        end
      end
    end

    def upload_data_bags
      knife_upload = Chef::Knife::Upload.new
      self.force_upload(knife_upload)
      knife_upload.name_args = ["/data_bags/*"]
      knife_upload.run
    end

    def upload_cookbooks
      knife_upload = Chef::Knife::Upload.new
      self.force_upload(knife_upload)
      knife_upload.name_args = ["/cookbooks"]
      knife_upload.run
    end

    def upload_roles
      # because we store roles as .rb files I don't know why opscode lets you upload .rb files "data bag from file" but not by "knife upload"
      # nor do I understand the "role show" with no .rb format option... owell this solves the problem we are experiencing.   moving on!
      # again see this https://tickets.opscode.com/browse/CHEF-3984 to make sense of my whiny rants
      role_path = "#{config[:cookbook_path][0]}/../roles"
      roles = Dir.entries(role_path)
      roles.delete_if { |x| x !~ /\.json$|\.rb$/ }
      knife_role_from_file = Chef::Knife::RoleFromFile.new
      roles.each do |role|
        knife_role_from_file.name_args.push("#{role_path}/#{role}")
      end
      knife_role_from_file.run
    end

    def upload_environments
      knife_upload = Chef::Knife::Upload.new
      self.force_upload(knife_upload)
      knife_upload.name_args = ["/environments"]
      knife_upload.run
    end

  end
end
