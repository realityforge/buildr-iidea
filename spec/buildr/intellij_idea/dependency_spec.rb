require File.expand_path('../../../spec_helper', __FILE__)

describe "iidea:generate" do

  def order_entry_xpath
    "/module/component[@name='NewModuleRootManager']/orderEntry"
  end
  
  describe "with a single dependency" do
    describe "of type compile" do
      before do
        artifact('group:id:jar:1.0') { |t| write t.to_s }
        @foo = define "foo" do
          compile.with 'group:id:jar:1.0'
        end
        invoke_generate_task
      end

      it "generates one exported 'module-library' orderEntry in IML" do
        root_module_xml(@foo).should have_nodes("#{order_entry_xpath}[@type='module-library', @exported='']/library/CLASSES/root", 1)
      end
    end

    describe "with iml.main_dependencies override" do
      before do
        artifact('group:id:jar:1.0') { |t| write t.to_s }
        @foo = define "foo" do
          iml.main_dependencies << 'group:id:jar:1.0'
        end
        invoke_generate_task
      end

      it "generates one exported 'module-library' orderEntry in IML" do
        root_module_xml(@foo).should have_nodes("#{order_entry_xpath}[@type='module-library', @exported='']/library/CLASSES/root", 1)
      end
    end

    describe "of type test" do
      before do
        artifact('group:id:jar:1.0') { |t| write t.to_s }
        @foo = define "foo" do
          test.with 'group:id:jar:1.0'
        end
        invoke_generate_task
      end

      it "generates one non-exported 'module-library' orderEntry in IML" do
        root_module_xml(@foo).should have_nodes("#{order_entry_xpath}[@type='module-library' and @exported]/library/CLASSES/root", 0)
        root_module_xml(@foo).should have_nodes("#{order_entry_xpath}[@type='module-library']/library/CLASSES/root", 1)
      end
    end

    describe "with iml.test_dependencies override" do
      before do
        artifact('group:id:jar:1.0') { |t| write t.to_s }
        @foo = define "foo" do
          iml.test_dependencies << 'group:id:jar:1.0'
        end
        invoke_generate_task
      end

      it "generates one non-exported 'module-library' orderEntry in IML" do
        root_module_xml(@foo).should have_nodes("#{order_entry_xpath}[@type='module-library' and @exported]/library/CLASSES/root", 0)
        root_module_xml(@foo).should have_nodes("#{order_entry_xpath}[@type='module-library']/library/CLASSES/root", 1)
      end
    end

    describe "with sources artifact present" do
      before do
        artifact('group:id:jar:1.0') { |t| write t.to_s }
        artifact('group:id:jar:sources:1.0') { |t| write t.to_s }
        @foo = define "foo" do
          compile.with 'group:id:jar:1.0'
        end
        invoke_generate_task
      end

      it "generates 'module-library' orderEntry in IML with SOURCES specified" do
        root_module_xml(@foo).should have_nodes("#{order_entry_xpath}[@type='module-library', @exported='']/library/SOURCES/root", 1)
      end
    end

    describe "with local_repository_env_override set to nil" do
      before do
        artifact('group:id:jar:1.0') { |t| write t.to_s }
        @foo = define "foo" do
          iml.local_repository_env_override = nil
          compile.with 'group:id:jar:1.0'
        end
        invoke_generate_task
      end

      it "generates orderEntry with absolute path for classes jar" do
        root_module_xml(@foo).should match_xpath("#{order_entry_xpath}/library/CLASSES/root/@url",
                                                 "jar://$MODULE_DIR$/home/.m2/repository/group/id/1.0/id-1.0.jar!/")
      end
    end
    describe "with local_repository_env_override set to MAVEN_REPOSITORY" do
      before do
        artifact('group:id:jar:1.0') { |t| write t.to_s }
        @foo = define "foo" do
          iml.local_repository_env_override = 'MAVEN_REPOSITORY'
          compile.with 'group:id:jar:1.0'
        end
        invoke_generate_task
      end

      it "generates orderEntry with absolute path for classes jar" do
        root_module_xml(@foo).should match_xpath("#{order_entry_xpath}/library/CLASSES/root/@url",
                                                 "jar://$MAVEN_REPOSITORY$/group/id/1.0/id-1.0.jar!/")
      end
    end
  end

  describe "with multiple dependencies" do
    before do
      artifact('group:id:jar:1.0') { |t| write t.to_s }
      artifact('group:id2:jar:1.0') { |t| write t.to_s }
      @foo = define "foo" do
        compile.with 'group:id:jar:1.0', 'group:id2:jar:1.0'
      end
      invoke_generate_task
    end

    it "generates multiple 'module-library' orderEntry in IML" do
      root_module_xml(@foo).should have_nodes("#{order_entry_xpath}[@type='module-library']", 2)
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
      root_module_xml(@foo).should match_xpath("#{order_entry_xpath}/library/CLASSES/root/@url",
                                               "jar://$MODULE_DIR$/foo-dep.jar!/")
    end
  end
end