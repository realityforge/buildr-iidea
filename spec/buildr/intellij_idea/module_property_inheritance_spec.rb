require File.expand_path('../../../spec_helper', __FILE__)

describe "Buildr::IntellijIdea::IdeaModule" do
  describe "settings inherited in subprojects" do
    before do
      mkdir_p 'bar'
      @foo = define "foo" do
        iml.type = "FOO_MODULE_TYPE"
        define 'bar'
      end
      invoke_generate_task
    end

    it "generates root IML with specified type" do
      module_file = root_module_filename(@foo)
      File.should be_exist(module_file)
      File.read(module_file).should =~ /FOO_MODULE_TYPE/
    end

    it "generates subproject IML with inherited type" do
      module_file = subproject_module_filename(@foo, "bar")
      File.should be_exist(module_file)
      File.read(module_file).should =~ /FOO_MODULE_TYPE/
    end
  end

end
