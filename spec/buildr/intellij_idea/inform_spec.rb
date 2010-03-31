require File.expand_path('../../../spec_helper', __FILE__)

MODULE_ENTRY_XPATH = "/project/component[@name='ProjectModuleManager']/modules/module"

describe "generate task" do
  describe "with a single project definition" do
    before do
      @foo = define "foo"
    end

    it "informs the user about generating IPR" do
      lambda { task('iidea').invoke }.should show_info(/Writing (.+)\/foo\.ipr/)
    end

    it "informs the user about generating IML" do
      lambda { task('iidea').invoke }.should show_info(/Writing (.+)\/foo\.iml/)
    end
  end
  describe "with a subproject" do
    before do
      @foo = define "foo" do
        define 'bar'
      end
    end

    it "informs the user about generating subporoject IML" do
      lambda { task('iidea').invoke }.should show_info(/Writing (.+)\/bar\/bar\.iml/)
    end
  end
end
