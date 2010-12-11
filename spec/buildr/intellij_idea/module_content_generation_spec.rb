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

  describe "with iml.skip_content! not specified and standard layout" do
    before do
      @foo = define "foo" do
      end
      invoke_generate_task
    end

    it "generate an IML with content section" do
      root_module_xml(@foo).should have_xpath("/module/component[@name='NewModuleRootManager']/content")
    end

    it "generate an exclude in content section for reports" do
      root_module_xml(@foo).should have_xpath("/module/component[@name='NewModuleRootManager']/content/excludeFolder[@url='file://$MODULE_DIR$/reports']")
    end

    it "generate an exclude in content section for target" do
      root_module_xml(@foo).should have_xpath("/module/component[@name='NewModuleRootManager']/content/excludeFolder[@url='file://$MODULE_DIR$/target']")
    end
  end

  describe "with subprojects" do
    before do
      @foo = define "foo" do
        define "bar" do
          compile.from _(:source, :main, :bar)
        end
      end
      invoke_generate_task
      @bar_doc = xml_document(project('foo:bar')._('bar.iml'))
    end

    it "generates the correct source directories" do
      @bar_doc.should have_xpath("//content/sourceFolder[@url='file://$MODULE_DIR$/src/main/bar']")
    end

    it "generates the correct exclude directories" do
      @bar_doc.should have_xpath("//content/excludeFolder[@url='file://$MODULE_DIR$/target']")
    end
  end

  describe "with overrides" do
    before do
      @foo = define "foo" do
        compile.from _(:source, :main, :bar)
        iml.main_source_directories << _(:source, :main, :baz)
        iml.test_source_directories << _(:source, :test, :foo)
      end
      invoke_generate_task
    end

    it "generates the correct main source directories" do
      root_module_xml(@foo).should have_xpath("//content/sourceFolder[@url='file://$MODULE_DIR$/src/main/baz' and @isTestSource='false']")
    end

    it "generates the correct test source directories" do
      root_module_xml(@foo).should have_xpath("//content/sourceFolder[@url='file://$MODULE_DIR$/src/test/foo' and @isTestSource='true']")
    end
  end

  describe "with report dir outside content" do
    before do
      layout = Layout::Default.new
      layout[:reports] = "../reports"

      @foo = define "foo", :layout => layout do
      end
      invoke_generate_task
    end

    it "generate an exclude in content section for target" do
      root_module_xml(@foo).should have_xpath("/module/component[@name='NewModuleRootManager']/content/excludeFolder[@url='file://$MODULE_DIR$/target']")
    end

    it "generates an content section without an exclude for report dir" do
      root_module_xml(@foo).should have_nodes("/module/component[@name='NewModuleRootManager']/content/excludeFolder", 1)
    end
  end

  describe "with target dir outside content" do
    before do
      layout = Layout::Default.new
      layout[:target] = "../target"
      layout[:target, :main] = "../target"

      @foo = define "foo", :layout => layout do
      end
      invoke_generate_task
    end

    it "generate an exclude in content section for reports" do
      root_module_xml(@foo).should have_xpath("/module/component[@name='NewModuleRootManager']/content/excludeFolder[@url='file://$MODULE_DIR$/reports']")
    end

    it "generates an content section without an exclude for target dir" do
      root_module_xml(@foo).should have_nodes("/module/component[@name='NewModuleRootManager']/content/excludeFolder", 1)
    end
  end
end
