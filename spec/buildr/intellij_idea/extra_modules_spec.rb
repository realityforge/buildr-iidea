require File.expand_path('../../../spec_helper', __FILE__)

describe "iidea:generate" do
  describe "with extra_modules specified" do
    before do
      @foo = define "foo" do
        ipr.extra_modules << 'other.iml'
        ipr.extra_modules << 'other_other.iml'
      end
      invoke_generate_task
    end

    it "generate an IPR with extra modules specified" do
      doc = xml_document(@foo._("foo.ipr"))
      doc.should have_nodes("#{xpath_to_module}", 3)
      module_ref = "$PROJECT_DIR$/foo.iml"
      doc.should have_xpath("#{xpath_to_module}[@fileurl='file://#{module_ref}', @filepath='#{module_ref}']")
      module_ref = "$PROJECT_DIR$/other.iml"
      doc.should have_xpath("#{xpath_to_module}[@fileurl='file://#{module_ref}', @filepath='#{module_ref}']")
      module_ref = "$PROJECT_DIR$/other_other.iml"
      doc.should have_xpath("#{xpath_to_module}[@fileurl='file://#{module_ref}', @filepath='#{module_ref}']")
    end
  end
end
