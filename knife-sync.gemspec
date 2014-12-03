# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'knife-sync/version'

Gem::Specification.new do |s|
  s.name = 'knife-sync'
  s.version = Knife::Sync::VERSION
  s.platform = Gem::Platform::RUBY
  s.has_rdoc = true
  s.extra_rdoc_files = ["README.rdoc", "LICENSE" ]
  s.summary = "Quick sync of chef-repo to multiple chef servers"
  s.description = s.summary
  s.author = "Curtis Downing"
  s.email = "curtis.downing@gmail.com"
  s.homepage = "http://themouthful.com"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.add_dependency "chef", ">= 0.10.0"
  s.require_paths = ['lib']
end
