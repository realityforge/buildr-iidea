require File.expand_path('../../../spec_helper', __FILE__)

describe "iidea:generate" do
  describe "with compile.options.source = '1.6'" do

    before do
      @foo = define "foo" do
        compile.options.source = '1.5'
      end
      invoke_generate_task
    end

    it "generate an ProjectRootManager with 1.5 jdk specified" do
      #raise File.read(@foo._("foo.ipr"))
      xml_document(@foo._("foo.ipr")).
          should have_xpath("/project/component[@name='ProjectRootManager' and @project-jdk-name = '1.5' and @languageLevel = 'JDK_1_5']")
    end

    it "generates a ProjectDetails component with the projectName option set" do
      xml_document(@foo._("foo.ipr")).
          should have_xpath("/project/component[@name='ProjectDetails']/option[@name = 'projectName' and @value = 'foo']")
    end
  end

  describe "with compile.options.source = '1.6'" do
    before do
      @foo = define "foo" do
        compile.options.source = '1.6'
      end
      invoke_generate_task
    end

    it "generate an ProjectRootManager with 1.6 jdk specified" do
      xml_document(@foo._("foo.ipr")).
          should have_xpath("/project/component[@name='ProjectRootManager' and @project-jdk-name = '1.6' and @languageLevel = 'JDK_1_6']")
    end
  end
end
