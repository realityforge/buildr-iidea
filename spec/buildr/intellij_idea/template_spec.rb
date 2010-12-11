require File.expand_path('../../../spec_helper', __FILE__)

describe "templates" do

  def ipr_template
    return <<PROJECT_XML
<?xml version="1.0" encoding="UTF-8"?>
<project version="4">
  <component name="SvnBranchConfigurationManager">
    <option name="mySupportsUserInfoFilter" value="false" />
  </component>
</project>
PROJECT_XML
  end

  def ipr_existing
    return <<PROJECT_XML
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
  end

  def ipr_from_template_xpath
    "/project/component[@name='SvnBranchConfigurationManager']/option[@name = 'mySupportsUserInfoFilter' and @value = 'false']"
  end

  def ipr_from_existing_xpath
    "/project/component[@name='AntConfiguration']"
  end

  def ipr_from_existing_shadowing_template_xpath
    "/project/component[@name='SvnBranchConfigurationManager']/option[@name = 'mySupportsUserInfoFilter' and @value = 'true']"
  end

  def ipr_from_existing_shadowing_generated_xpath
    "/project/component[@name='ProjectModuleManager']/modules/module[@fileurl = 'file://$PROJECT_DIR$/existing.iml']"
  end

  def ipr_from_generated_xpath
    "/project/component[@name='ProjectModuleManager']/modules/module[@fileurl = 'file://$PROJECT_DIR$/foo.iml']"
  end

  def iml_template
    return <<PROJECT_XML
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
  end

  def iml_existing
    return <<PROJECT_XML
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
  end

  def iml_from_template_xpath
    "/module/component[@name='FacetManager']/facet[@type = 'JRUBY']"
  end

  def iml_from_existing_xpath
    "/module/component[@name='FunkyPlugin']"
  end

  def iml_from_existing_shadowing_template_xpath
    "/module/component[@name='FacetManager']/facet[@type = 'SCALA']"
  end

  def iml_from_existing_shadowing_generated_xpath
    "/module/component[@name='NewModuleRootManager']/orderEntry[@module-name = 'buildr-bnd']"
  end

  def iml_from_generated_xpath
    "/module/component[@name='NewModuleRootManager']/orderEntry[@type = 'module-library']"
  end

  describe "with existing project files" do
    before do
      write "foo.ipr", ipr_existing
      write "foo.iml", iml_existing
      artifact('group:id:jar:1.0') { |t| write t.to_s }
      @foo = define "foo" do
        ipr.template = nil
        iml.template = nil
        compile.with 'group:id:jar:1.0'
      end
      invoke_generate_task
    end

    it "replaces ProjectModuleManager component in existing ipr file" do
      xml_document(@foo._("foo.ipr")).should have_xpath(ipr_from_generated_xpath)
      xml_document(@foo._("foo.ipr")).should_not have_xpath(ipr_from_existing_shadowing_generated_xpath)
    end

    it "merges component in existing ipr file" do
      xml_document(@foo._("foo.ipr")).should have_xpath(ipr_from_existing_xpath)
    end

    def iml_from_generated_xpath
      "/module/component[@name='NewModuleRootManager']/orderEntry[@type = 'module-library']"
    end

    it "replaces NewModuleRootManager component in existing iml file" do
      xml_document(@foo._("foo.iml")).should have_xpath(iml_from_generated_xpath)
      xml_document(@foo._("foo.iml")).should_not have_xpath(iml_from_existing_shadowing_generated_xpath)
    end

    it "merges component in existing iml file" do
      xml_document(@foo._("foo.iml")).should have_xpath(iml_from_existing_xpath)
    end
  end

  describe "with an iml template" do
    before do
      write "module.template.iml", iml_template
      artifact('group:id:jar:1.0') { |t| write t.to_s }
      @foo = define "foo" do
        ipr.template = nil
        iml.template = "module.template.iml"
        compile.with 'group:id:jar:1.0'
      end
      invoke_generate_task
    end

    it "replaces generated components" do
      xml_document(@foo._("foo.iml")).should have_xpath(iml_from_generated_xpath)
    end

    it "merges component in iml template" do
      xml_document(@foo._("foo.iml")).should have_xpath(iml_from_template_xpath)
    end
  end

  describe "with an iml template and existing iml" do
    before do
      write "module.template.iml", iml_template
      write "foo.iml", iml_existing
      artifact('group:id:jar:1.0') { |t| write t.to_s }
      @foo = define "foo" do
        ipr.template = nil
        iml.template = "module.template.iml"
        compile.with 'group:id:jar:1.0'
      end
      invoke_generate_task
    end

    it "replaces generated components" do
      xml_document(@foo._("foo.iml")).should have_xpath(iml_from_generated_xpath)
    end

    it "merges component in iml template" do
      xml_document(@foo._("foo.iml")).should have_xpath(iml_from_template_xpath)
    end

    it "merges components not in iml template and not generated by task" do
      xml_document(@foo._("foo.iml")).should have_xpath(iml_from_existing_xpath)
      xml_document(@foo._("foo.iml")).should_not have_xpath(iml_from_existing_shadowing_template_xpath)
      xml_document(@foo._("foo.iml")).should_not have_xpath(iml_from_existing_shadowing_generated_xpath)
    end
  end

  describe "with an ipr template" do
    before do
      write "project.template.iml", ipr_template
      artifact('group:id:jar:1.0') { |t| write t.to_s }
      @foo = define "foo" do
        ipr.template = "project.template.iml"
        iml.template = nil
        compile.with 'group:id:jar:1.0'
      end
      invoke_generate_task
    end

    it "replaces generated component in ipr template" do
      xml_document(@foo._("foo.ipr")).should have_xpath(ipr_from_generated_xpath)
    end

    it "merges component in ipr template" do
      xml_document(@foo._("foo.ipr")).should have_xpath(ipr_from_template_xpath)
    end
  end

  describe "with an ipr template and existing ipr" do
    before do
      write "project.template.iml", ipr_template
      write "foo.ipr", ipr_existing
      artifact('group:id:jar:1.0') { |t| write t.to_s }
      @foo = define "foo" do
        ipr.template = "project.template.iml"
        iml.template = nil
        compile.with 'group:id:jar:1.0'
      end
      invoke_generate_task
    end

    it "replaces generated component in ipr template" do
      xml_document(@foo._("foo.ipr")).should have_xpath(ipr_from_generated_xpath)
    end

    it "merges component in ipr template" do
      xml_document(@foo._("foo.ipr")).should have_xpath(ipr_from_template_xpath)
    end

    it "merges components not in ipr template and not generated by task" do
      xml_document(@foo._("foo.ipr")).should have_xpath(ipr_from_existing_xpath)
      xml_document(@foo._("foo.ipr")).should_not have_xpath(ipr_from_existing_shadowing_generated_xpath)
      xml_document(@foo._("foo.ipr")).should_not have_xpath(ipr_from_existing_shadowing_template_xpath)
    end
  end
end