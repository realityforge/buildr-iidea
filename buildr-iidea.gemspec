Gem::Specification.new do |spec|
  spec.name           = 'buildr-iidea'
  spec.version        = '0.0.0.pre'
  spec.author         = 'Rhett Sutphin'
  spec.email          = "rhett@detailedbalance.net"
  spec.homepage       = "http://github.com/rsutphin/buildr-iidea"
  spec.summary        = "Better buildr tasks to generate Intellij IDEA project files"
  spec.description    = <<-TEXT
iidea is a set of buildr tasks which generate Intellij IDEA project files.  
Better defaults and more configurable than the built-in idea7x task.
  TEXT
  #spec.rubyforge_project  = 'buildr-iidea'

  spec.platform       = RUBY_PLATFORM[/java/]
  
  spec.files          = Dir['{lib,spec}/**/*', '*.gemspec'] +
                        ['LICENSE', 'NOTICE', 'CHANGELOG', 'README.markdown', 'Rakefile']
  spec.require_paths  = 'lib'

  spec.has_rdoc         = true
  spec.extra_rdoc_files = 'README.markdown', 'CHANGELOG', 'LICENSE', 'NOTICE'
  spec.rdoc_options     = '--title', 'Buildr iidea', '--main', 'README.markdown'

  #TODO: Can this be made into a range of version compatibility?
  spec.add_dependency 'buildr',           '1.4.0'
end
