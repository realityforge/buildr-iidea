Gem::Specification.new do |spec|
  spec.name           = 'buildr-iidea'
  spec.version        = `git describe`.strip.split('-').first
  spec.author         = 'Rhett Sutphin'
  spec.email          = "rhett@detailedbalance.net"
  spec.homepage       = "http://github.com/rsutphin/buildr-iidea"
  spec.summary        = "Buildr tasks to generate Intellij IDEA project files"
  spec.description    = <<-TEXT
This is a buildr extension that provides tasks to generate Intellij IDEA
project files. The iidea task generates the project files based on the
settings of each project and extension specific settings. 
  TEXT

  spec.platform       = RUBY_PLATFORM[/java/]
  
  spec.files          = Dir['{lib,spec}/**/*', '*.gemspec'] +
                        ['LICENSE', 'NOTICE', 'README.rdoc', 'Rakefile']
  spec.require_paths  = 'lib'

  spec.has_rdoc         = true
  spec.extra_rdoc_files = 'README.rdoc', 'LICENSE', 'NOTICE'
  spec.rdoc_options     = '--title', "#{spec.name} #{spec.version}", '--main', 'README.rdoc'

  spec.add_dependency 'buildr',           '1.4.0'
end
