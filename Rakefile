begin
  require File.expand_path('../.bundle/environment', __FILE__)
rescue LoadError
  raise "Gem environment is locked but not installed. Run `bundle install` and then try again."
end

require 'rake'

# TODO: submit to jeweler
class GemfileGemspecCreator
  def initialize(gemspec)
    @gemspec = gemspec
    instance_eval File.read('Gemfile')
  end

  def gem(name, version=nil)
    case @group.to_sym
    when :development
      @gemspec.add_development_dependency(name, version)
    when :runtime
      @gemspec.add_dependency(name, version)
    end
  end

  def group(group_name)
    @group = group_name
    yield if block_given?
    @group = nil
  end

  def method_missing(name, *args)
    # ignore
  end
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "buildr-iidea"
    gem.summary = %Q{Better buildr tasks to generate Intellij IDEA project files}
    gem.description = %Q{iidea is a set of buildr tasks which generate Intellij IDEA project files.  Better defaults and more configurable than the built-in idea7x task.}
    gem.email = "rhett@detailedbalance.net"
    gem.homepage = "http://github.com/rsutphin/buildr-iidea"
    gem.authors = ["Rhett Sutphin"]

    GemfileGemspecCreator.new(gem)

    # Exclude test-only vendored buildr
    gem.files.exclude("vendor/**/*")
  end
  Jeweler::GemcutterTasks.new
rescue LoadError => e
  $stderr.puts e
  $stderr.puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :spec

task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "buildr-iidea #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
