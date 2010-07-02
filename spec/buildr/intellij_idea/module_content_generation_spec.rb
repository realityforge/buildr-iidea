require File.expand_path('../../../spec_helper', __FILE__)

describe "iidea:generate" do
  describe "with iml.skip_content! specified" do
    before do
      @foo = define "foo" do
        iml.skip_content!
      end
      invoke_generate_task
    end

    it "generate an IML with no content section" do
      doc = xml_document(@foo._(root_module_filename(@foo)))
      doc.should_not have_xpath("/module/component[@name='NewModuleRootManager']/content")
    end
  end

  describe "with iml.skip_content! not specified" do
    before do
      @foo = define "foo" do
      end
      invoke_generate_task
    end

    it "generate an IML with content section" do
      doc = xml_document(@foo._(root_module_filename(@foo)))
      doc.should have_xpath("/module/component[@name='NewModuleRootManager']/content")
    end
  end
end
