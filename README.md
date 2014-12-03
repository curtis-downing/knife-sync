# knife-sync

# Requirements
* GPG encrypted encrypted secrets
* knife plugins
  * knife-block - https://github.com/greenandsecure/knife-block
* Gems
  * net/http

***

# Additions to knife.rb

Make sure to add the following to your knife.rb file

```ruby
if ::File.exist?(File.expand_path("#{ENV['HOME']}/.chef/knife.company.rb", __FILE__))
  Chef::Config.from_file(File.expand_path("#{ENV['HOME']}/.chef/knife.company.rb", __FILE__))
end
```

# knife.comany.rb

Make sure you have an entry similar to the following.  Adjust accordingly but these are all the chef servers you intentd to sync to.  The names are what you set up in knife-block.

```ruby
my_knife_blocks                ["production","aws","my_dev"]
```

knife-sync deals with wrapping around some already useful knife plugins which should simplify things even futher.  It also addresses some interanal needs that could certainly be refactored
into something more generic: for example:
  We have dynamic data bags for users.  Our gitlab server runs a script that updates user SSH keys when they changes.  When using this command (uploading data bags in general) it wipes out the dynamic data changes
  which are SSH keys.  We could wait for the cron to schedule it, but we want to trigger an event on the jenkins server to resync up the keys.  Why on jenkins?  It beomes a trackable event and jenkins is good about
  recording trends and there could be instances when running a job manually is needed.  It's possible we will move it to a message queue as things mature.

***

# Usage

***

# TODO
* auto query environments from chef-repo instead of requiring them in knife.rb
* make block environments query and flaggable
