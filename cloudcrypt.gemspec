# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "cloudcrypt/version"

Gem::Specification.new do |s|
  s.name        = "cloudcrypt"
  s.version     = Cloudcrypt::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Rodrigo Estebanez"]
  s.email       = ["restebanez@mdsol.com"]
  s.homepage    = ""
  s.summary     = %q{encrypt and decrypt files using public and private encryption}
  s.description = %q{You can't encrypt a file bigger than the private key. You first have to generate a random key and a random vector initialization to encrypt the file using a symmetrical algorithom. Later you use the private key to encrypt the random key and the random vector}

  s.rubyforge_project = "cloudcrypt"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.default_executable = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
#  s.executables = ["cloudcrypt.rb"]
#  s.default_executable = 'cloudcrypt.rb'
  
  s.add_dependency('fog')
  s.add_dependency('rubyzip')
  s.add_dependency('trollop')  
end
