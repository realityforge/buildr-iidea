require File.expand_path('../../../spec_helper', __FILE__)

describe "IdeaModule" do
  describe "settings inherited in subprojects" do
    before do
      mkdir_p 'bar'
      @foo = define "foo" do
        iml.type = "FOO_MODULE_TYPE"
        define 'bar'
      end
      task('iidea').invoke
    end

    it "generates root IML with specified type" do
      module_file = @foo._("foo#{Buildr::IntellijIdea::Config.suffix}.iml")
      File.should be_exist(module_file)
      File.read(module_file).should =~ /FOO_MODULE_TYPE/
    end

    it "generates subproject IML with inherited type" do
      module_file = @foo._("bar/foo-bar#{Buildr::IntellijIdea::Config.suffix}.iml")
      File.should be_exist(module_file)
      File.read(module_file).should =~ /FOO_MODULE_TYPE/
    end
  end

end
