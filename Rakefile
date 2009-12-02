# Look in the tasks/setup.rb file for the various options that can be
# configured in this Rakefile. The .rake files in the tasks directory
# are where the options are used.

begin
  require 'bones'
  Bones.setup
rescue LoadError
  begin
    load 'tasks/setup.rb'
  rescue LoadError
    raise RuntimeError, '### please install the "bones" gem ###'
  end
end

ensure_in_path 'lib'
require 'snapshoter'

task :default => 'spec:run'

PROJ.name = 'snapshoter'
PROJ.authors = 'Kris Rasmussen'
PROJ.email = 'Kris Rasmussen'
PROJ.url = 'http://www.dreamthis.com'
PROJ.version = Snapshoter::VERSION
PROJ.rubyforge.name = 'snapshoter'
PROJ.spec.opts << '--color'

# use hanna template for rdoc
require 'hanna/rdoctask'

depend_on 'right_aws'

# EOF
