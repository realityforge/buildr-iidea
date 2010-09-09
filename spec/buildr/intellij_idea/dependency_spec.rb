require File.expand_path('../../../spec_helper', __FILE__)

ORDER_ENTRY_XPATH = "/module/component[@name='NewModuleRootManager']/orderEntry"
DEPENDENCY_NAME = 'group:id:jar:1.0'
DEPENDENCY_SOURCES_NAME = 'group:id:jar:sources:1.0'
DEPENDENCY2_NAME = 'group:id2:jar:1.0'

describe "iidea:generate" do

  describe "with a single dependency" do
    before do
      @artifact = artifact(DEPENDENCY_NAME) { |t| write t.to_s }
    end

    describe "of type compile" do
      before do
        @foo = define "foo" do
          compile.with DEPENDENCY_NAME
        end
        invoke_generate_task
      end

      it "generates one exported 'module-library' orderEntry in IML" do
        root_module_xml(@foo).should have_nodes("#{ORDER_ENTRY_XPATH}[@type='module-library', @exported='']/library/CLASSES/root", 1)
      end
    end

    describe "of type test" do
      before do
        @foo = define "foo" do
          test.with DEPENDENCY_NAME
        end
        invoke_generate_task
      end

      it "generates one non-exported 'module-library' orderEntry in IML" do
        root_module_xml(@foo).should have_nodes("#{ORDER_ENTRY_XPATH}[@type='module-library' and @exported]/library/CLASSES/root", 0)
        root_module_xml(@foo).should have_nodes("#{ORDER_ENTRY_XPATH}[@type='module-library']/library/CLASSES/root", 1)
      end
    end

    describe "with sources artifact present" do
      before do
        artifact(DEPENDENCY_SOURCES_NAME) { |t| write t.to_s }
        @foo = define "foo" do
          compile.with DEPENDENCY_NAME
        end
        invoke_generate_task
      end

      it "generates 'module-library' orderEntry in IML with SOURCES specified" do
        root_module_xml(@foo).should have_nodes("#{ORDER_ENTRY_XPATH}[@type='module-library', @exported='']/library/SOURCES/root", 1)
      end
    end

    describe "with local_repository_env_override set to nil" do
      before do
        @foo = define "foo" do
          iml.local_repository_env_override = nil
          compile.with DEPENDENCY_NAME
        end
        invoke_generate_task
      end

      it "generates orderEntry with absolute path for classes jar" do
        root_module_xml(@foo).should match_xpath("#{ORDER_ENTRY_XPATH}/library/CLASSES/root/@url",
                                                 "jar://$MODULE_DIR$/home/.m2/repository/group/id/1.0/id-1.0.jar!/")
      end
    end
    describe "with local_repository_env_override set to MAVEN_REPOSITORY" do
      before do
        @foo = define "foo" do
          iml.local_repository_env_override = 'MAVEN_REPOSITORY'
          compile.with DEPENDENCY_NAME
        end
        invoke_generate_task
      end

      it "generates orderEntry with absolute path for classes jar" do
        root_module_xml(@foo).should match_xpath("#{ORDER_ENTRY_XPATH}/library/CLASSES/root/@url",
                                                 "jar://$MAVEN_REPOSITORY$/group/id/1.0/id-1.0.jar!/")
      end
    end
  end

  describe "with multiple dependencies" do
    before do
      @artifact1 = artifact(DEPENDENCY_NAME) { |t| write t.to_s }
      @artifact2 = artifact(DEPENDENCY2_NAME) { |t| write t.to_s }
      @foo = define "foo" do
        compile.with DEPENDENCY_NAME, DEPENDENCY2_NAME
      end
      invoke_generate_task
    end

    it "generates multiple 'module-library' orderEntry in IML" do
      root_module_xml(@foo).should have_nodes("#{ORDER_ENTRY_XPATH}[@type='module-library']", 2)
    end
  end

  describe "with a single non artifact dependency" do
    before do
      @foo = define "foo" do
        filename = _("foo-dep.jar")
        File.open(filename,"wb") { |t| write "Hello" }
        compile.with filename
      end
      invoke_generate_task
    end

    it "generates one exported 'module-library' orderEntry in IML" do
      root_module_xml(@foo).should match_xpath("#{ORDER_ENTRY_XPATH}/library/CLASSES/root/@url",
                                               "jar://$MODULE_DIR$/foo-dep.jar!/")
    end
  end
end