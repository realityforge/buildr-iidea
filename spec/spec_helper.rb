DEFAULT_BUILDR_DIR=File.expand_path(File.dirname(__FILE__) + '/../../buildr')
BUILDR_DIR =
  begin
    if ENV['BUILDR_DIR']
      ENV['BUILDR_DIR']
    elsif File.exist?(File.expand_path('../buildr_dir', __FILE__))
      File.read(File.expand_path('../buildr_dir', __FILE__)).strip
    else
      DEFAULT_BUILDR_DIR
    end
  end

unless File.exist?("#{BUILDR_DIR}/buildr.gemspec")
  raise "Unable to find buildr.gemspec in #{BUILDR_DIR == DEFAULT_BUILDR_DIR ? 'guessed' : 'specified'} $BUILDR_DIR (#{BUILDR_DIR})"
end

# hook into buildr's spec_helpers load process
module SandboxHook
  def SandboxHook.included(spec_helpers)
    $LOAD_PATH.unshift(File.dirname(__FILE__))
    $LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
    require 'buildr_iidea'
  end
end

begin
  require File.expand_path("#{BUILDR_DIR}/lib/buildr/version.rb")
  require File.expand_path("#{BUILDR_DIR}/spec/spec_helpers.rb")
rescue Exception => e
  $stderr.puts "Error initializing the build environment\n"
  $stderr.puts "Cause: #{e.inspect}\n"
  exit(22)
end

require File.expand_path(File.dirname(__FILE__) + '/xpath_matchers.rb')
