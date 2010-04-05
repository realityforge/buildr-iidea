require File.expand_path('../../../spec_helper', __FILE__)

describe "iidea:generate" do
  describe "with iml.group specified" do
    before do
      @foo = define "foo" do
        iml.group = true
        define 'bar' do
          define 'baz' do

          end
        end
        define 'rab' do
          iml.group = "MyGroup"
        end
      end
      invoke_generate_task
    end

    it "generate an IPR with correct group references" do
      doc = xml_document(@foo._("foo.ipr"))
      doc.should have_nodes("#{xpath_to_module}", 4)
      module_ref = "$PROJECT_DIR$/foo.iml"
      doc.should have_xpath("#{xpath_to_module}[@fileurl='file://#{module_ref}', @filepath='#{module_ref}']")
      module_ref = "$PROJECT_DIR$/rab/rab.iml"
      doc.should have_xpath("#{xpath_to_module}[@fileurl='file://#{module_ref}', @filepath='#{module_ref}' @group = 'MyGroup']")
      module_ref = "$PROJECT_DIR$/bar/bar.iml"
      doc.should have_xpath("#{xpath_to_module}[@fileurl='file://#{module_ref}', @filepath='#{module_ref}' @group = 'foo']")
      module_ref = "$PROJECT_DIR$/bar/baz/baz.iml"
      doc.should have_xpath("#{xpath_to_module}[@fileurl='file://#{module_ref}', @filepath='#{module_ref}' @group = 'foo/bar']")
    end
  end
end
