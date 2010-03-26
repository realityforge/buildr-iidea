require File.expand_path('../../../spec_helper', __FILE__)

describe "iidea" do
  describe "Dependency uses M2_REPO environment variable by default" do
    before do
      mkdir_p 'src/main/java'

      artifact('group:id:jar:1.0') { |t| write t.to_s }

      @foo = define "foo" do
        compile.with 'group:id:jar:1.0'
      end
      task('iidea').invoke
    end

    it "generates IML with a dependency" do
      module_file = @foo._("foo#{Buildr::IntellijIdea::Config.suffix}.iml")
      File.should be_exist(module_file)
      File.read(module_file).should =~ /jar:\/\/\$M2_REPO\$\/group\/id\/1\.0\/id-1\.0\.jar\!\//
    end
  end

end
