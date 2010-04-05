require File.expand_path('../../../spec_helper', __FILE__)

IPR_TEMPLATE_NAME = "project.template.iml"

IPR_TEMPLATE = <<PROJECT_XML
<?xml version="1.0" encoding="UTF-8"?>
<project version="4">
  <component name="SvnBranchConfigurationManager">
    <option name="mySupportsUserInfoFilter" value="false" />
  </component>
</project>
PROJECT_XML

IPR_EXISTING = <<PROJECT_XML
<?xml version="1.0" encoding="UTF-8"?>
<project version="4">
  <component name="AntConfiguration">
    <defaultAnt bundledAnt="true" />
  </component>
  <component name="SvnBranchConfigurationManager">
    <option name="mySupportsUserInfoFilter" value="true" />
  </component>
  <component name="ProjectModuleManager">
    <modules>
      <module fileurl="file://$PROJECT_DIR$/existing.iml" filepath="$PROJECT_DIR$/existing.iml" />
    </modules>
  </component>
</project>
PROJECT_XML

IPR_FROM_TEMPLATE_XPATH = <<XPATH
/project/component[@name='SvnBranchConfigurationManager']/option[@name = 'mySupportsUserInfoFilter' and @value = 'false']
XPATH

IPR_FROM_EXISTING_XPATH = <<XPATH
/project/component[@name='AntConfiguration']
XPATH

IPR_FROM_EXISTING_SHADOWING_TEMPLATE_XPATH = <<XPATH
/project/component[@name='SvnBranchConfigurationManager']/option[@name = 'mySupportsUserInfoFilter' and @value = 'true']
XPATH

IPR_FROM_EXISTING_SHADOWING_GENERATED_XPATH = <<XPATH
/project/component[@name='ProjectModuleManager']/modules/module[@fileurl = 'file://$PROJECT_DIR$/existing.iml']
XPATH

IPR_FROM_GENERATED_XPATH = <<XPATH
/project/component[@name='ProjectModuleManager']/modules/module[@fileurl = 'file://$PROJECT_DIR$/foo.iml']
XPATH

IML_TEMPLATE_NAME = "module.template.iml"

IML_TEMPLATE = <<PROJECT_XML
<?xml version="1.0" encoding="UTF-8"?>
<module type="JAVA_MODULE" version="4">
  <component name="FacetManager">
    <facet type="JRUBY" name="JRuby">
      <configuration number="0">
        <JRUBY_FACET_CONFIG_ID NAME="JRUBY_SDK_NAME" VALUE="JRuby SDK 1.4.0RC1" />
      </configuration>
    </facet>
  </component>
</module>
PROJECT_XML

IML_EXISTING = <<PROJECT_XML
<?xml version="1.0" encoding="UTF-8"?>
<module type="JAVA_MODULE" version="4">
  <component name="FunkyPlugin"/>
  <component name="FacetManager">
    <facet type="SCALA" name="Scala"/>
  </component>
  <component name="NewModuleRootManager" inherit-compiler-output="true">
    <exclude-output />
    <content url="file://$MODULE_DIR$"/>
    <orderEntry type="inheritedJdk" />
    <orderEntry type="sourceFolder" forTests="false" />
    <orderEntry type="module" module-name="buildr-bnd" exported="" />
  </component>
</module>
PROJECT_XML

IML_FROM_TEMPLATE_XPATH = <<XPATH
/module/component[@name='FacetManager']/facet[@type = 'JRUBY']
XPATH

IML_FROM_EXISTING_XPATH = <<XPATH
/module/component[@name='FunkyPlugin']
XPATH

IML_FROM_EXISTING_SHADOWING_TEMPLATE_XPATH = <<XPATH
/module/component[@name='FacetManager']/facet[@type = 'SCALA']
XPATH

IML_FROM_EXISTING_SHADOWING_GENERATED_XPATH = <<XPATH
/module/component[@name='NewModuleRootManager']/orderEntry[@module-name = 'buildr-bnd']
XPATH

IML_FROM_GENERATED_XPATH = <<XPATH
/module/component[@name='NewModuleRootManager']/orderEntry[@type = 'module-library']
XPATH

describe "iidea:generate" do

  describe "with existing project files" do
    before do
      write "foo.ipr", IPR_EXISTING
      write "foo.iml", IML_EXISTING
      artifact('group:id:jar:1.0') { |t| write t.to_s }
      @foo = define "foo" do
        ipr.template = nil
        iml.template = nil
        compile.with 'group:id:jar:1.0'
      end
      invoke_generate_task
    end

    it "replaces ProjectModuleManager component in existing ipr file" do
      xml_document(@foo._("foo.ipr")).should have_xpath(IPR_FROM_GENERATED_XPATH)
      xml_document(@foo._("foo.ipr")).should_not have_xpath(IPR_FROM_EXISTING_SHADOWING_GENERATED_XPATH)
    end

    it "merges component in existing ipr file" do
      xml_document(@foo._("foo.ipr")).should have_xpath(IPR_FROM_EXISTING_XPATH)
    end

    it "replaces NewModuleRootManager component in existing iml file" do
      xml_document(@foo._("foo.iml")).should have_xpath(IML_FROM_GENERATED_XPATH)
      xml_document(@foo._("foo.iml")).should_not have_xpath(IML_FROM_EXISTING_SHADOWING_GENERATED_XPATH)
    end

    it "merges component in existing iml file" do
      xml_document(@foo._("foo.iml")).should have_xpath(IML_FROM_EXISTING_XPATH)
    end
  end

  describe "with an iml template" do
    before do
      write IML_TEMPLATE_NAME, IML_TEMPLATE
      artifact('group:id:jar:1.0') { |t| write t.to_s }
      @foo = define "foo" do
        ipr.template = nil
        iml.template = IML_TEMPLATE_NAME
        compile.with 'group:id:jar:1.0'
      end
      invoke_generate_task
    end

    it "replaces generated components" do
      xml_document(@foo._("foo.iml")).should have_xpath(IML_FROM_GENERATED_XPATH)
    end

    it "merges component in iml template" do
      xml_document(@foo._("foo.iml")).should have_xpath(IML_FROM_TEMPLATE_XPATH)
    end
  end

  describe "with an iml template and existing iml" do
    before do
      write IML_TEMPLATE_NAME, IML_TEMPLATE
      write "foo.iml", IML_EXISTING
      artifact('group:id:jar:1.0') { |t| write t.to_s }
      @foo = define "foo" do
        ipr.template = nil
        iml.template = IML_TEMPLATE_NAME
        compile.with 'group:id:jar:1.0'
      end
      invoke_generate_task
    end

    it "replaces generated components" do
      xml_document(@foo._("foo.iml")).should have_xpath(IML_FROM_GENERATED_XPATH)
    end

    it "merges component in iml template" do
      xml_document(@foo._("foo.iml")).should have_xpath(IML_FROM_TEMPLATE_XPATH)
    end

    it "merges components not in iml template and not generated by task" do
      xml_document(@foo._("foo.iml")).should have_xpath(IML_FROM_EXISTING_XPATH)
      xml_document(@foo._("foo.iml")).should_not have_xpath(IML_FROM_EXISTING_SHADOWING_TEMPLATE_XPATH)
      xml_document(@foo._("foo.iml")).should_not have_xpath(IML_FROM_EXISTING_SHADOWING_GENERATED_XPATH)
    end
  end

  describe "with an ipr template" do
    before do
      write IPR_TEMPLATE_NAME, IPR_TEMPLATE
      artifact('group:id:jar:1.0') { |t| write t.to_s }
      @foo = define "foo" do
        ipr.template = IPR_TEMPLATE_NAME
        iml.template = nil
        compile.with 'group:id:jar:1.0'
      end
      invoke_generate_task
    end

    it "replaces generated component in ipr template" do
      xml_document(@foo._("foo.ipr")).should have_xpath(IPR_FROM_GENERATED_XPATH)
    end

    it "merges component in ipr template" do
      xml_document(@foo._("foo.ipr")).should have_xpath(IPR_FROM_TEMPLATE_XPATH)
    end
  end

  describe "with an ipr template and existing ipr" do
    before do
      write IPR_TEMPLATE_NAME, IPR_TEMPLATE
      write "foo.ipr", IPR_EXISTING
      artifact('group:id:jar:1.0') { |t| write t.to_s }
      @foo = define "foo" do
        ipr.template = IPR_TEMPLATE_NAME
        iml.template = nil
        compile.with 'group:id:jar:1.0'
      end
      invoke_generate_task
    end

    it "replaces generated component in ipr template" do
      xml_document(@foo._("foo.ipr")).should have_xpath(IPR_FROM_GENERATED_XPATH)
    end

    it "merges component in ipr template" do
      xml_document(@foo._("foo.ipr")).should have_xpath(IPR_FROM_TEMPLATE_XPATH)
    end

    it "merges components not in ipr template and not generated by task" do
      xml_document(@foo._("foo.ipr")).should have_xpath(IPR_FROM_EXISTING_XPATH)
      xml_document(@foo._("foo.ipr")).should_not have_xpath(IPR_FROM_EXISTING_SHADOWING_GENERATED_XPATH)
      xml_document(@foo._("foo.ipr")).should_not have_xpath(IPR_FROM_EXISTING_SHADOWING_TEMPLATE_XPATH)
    end
  end
end