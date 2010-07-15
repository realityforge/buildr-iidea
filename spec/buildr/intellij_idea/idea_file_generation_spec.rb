require File.expand_path('../../../spec_helper', __FILE__)

describe "iidea:generate" do
  describe "with a single project definition" do
    describe "and default naming" do
      before do
        @foo = define "foo"
        invoke_generate_task
      end

      it "generates a single IPR" do
        Dir[@foo._("**/*.ipr")].should have(1).entry
      end

      it "generate an IPR in the root directory" do
        File.should be_exist(@foo._("foo.ipr"))
      end

      it "generates a single IML" do
        Dir[@foo._("**/*.iml")].should have(1).entry
      end

      it "generates an IML in the root directory" do
        File.should be_exist(@foo._("foo.iml"))
      end

      it "generate an IPR with the reference to correct module file" do
        File.should be_exist(@foo._("foo.ipr"))
        doc = xml_document(@foo._("foo.ipr"))
        module_ref = "$PROJECT_DIR$/foo.iml"
        doc.should have_nodes("#{xpath_to_module}[@fileurl='file://#{module_ref}', @filepath='#{module_ref}']", 1)
      end
    end

    describe "with no_iml generation disabled" do
      before do
        @foo = define "foo" do
          project.no_iml
        end
        invoke_generate_task
      end

      it "generates no IML" do
        Dir[@foo._("**/*.iml")].should have(0).entry
      end

      it "generate an IPR with no references" do
        File.should be_exist(@foo._("foo.ipr"))
        doc = xml_document(@foo._("foo.ipr"))
        doc.should have_nodes("#{xpath_to_module}", 0)
      end
    end

    describe "with ipr generation disabled" do
      before do
        @foo = define "foo" do
          project.no_ipr
        end
        invoke_generate_task
      end

      it "generates a single IML" do
        Dir[@foo._("**/*.iml")].should have(1).entry
      end

      it "generate no IPR" do
        File.should_not be_exist(@foo._("foo.ipr"))
      end
    end

    describe "and id overrides" do
      before do
        @foo = define "foo" do
          ipr.id = 'fooble'
          iml.id = 'feap'
          define "bar" do
            iml.id = "baz"
          end
        end
        invoke_generate_task
      end

      it "generate an IPR in the root directory" do
        File.should be_exist(@foo._("fooble.ipr"))
      end

      it "generates an IML in the root directory" do
        File.should be_exist(@foo._("feap.iml"))
      end

      it "generates an IML in the subproject directory" do
        File.should be_exist(@foo._("bar/baz.iml"))
      end

      it "generate an IPR with the reference to correct module file" do
        File.should be_exist(@foo._("fooble.ipr"))
        doc = xml_document(@foo._("fooble.ipr"))
        module_ref = "$PROJECT_DIR$/feap.iml"
        doc.should have_nodes("#{xpath_to_module}[@fileurl='file://#{module_ref}', @filepath='#{module_ref}']", 1)
      end
    end

    describe "and a suffix defined" do
      before do
        @foo = define "foo" do
          ipr.suffix = '-ipr-suffix'
          iml.suffix = '-iml-suffix'
        end
        invoke_generate_task
      end

      it "generate an IPR in the root directory" do
        File.should be_exist(@foo._("foo-ipr-suffix.ipr"))
      end

      it "generates an IML in the root directory" do
        File.should be_exist(@foo._("foo-iml-suffix.iml"))
      end

      it "generate an IPR with the reference to correct module file" do
        File.should be_exist(@foo._("foo-ipr-suffix.ipr"))
        doc = xml_document(@foo._("foo-ipr-suffix.ipr"))
        doc.should have_nodes("#{xpath_to_module}", 1)
        module_ref = "$PROJECT_DIR$/foo-iml-suffix.iml"
        doc.should have_nodes("#{xpath_to_module}[@fileurl='file://#{module_ref}', @filepath='#{module_ref}']", 1)
      end
    end
  end

  describe "with a subproject" do
    before do
      @foo = define "foo" do
        define 'bar'
      end
      invoke_generate_task
    end

    it "creates the subproject directory" do
      File.should be_exist(@foo._("bar"))
    end

    it "generates an IML in the subproject directory" do
      File.should be_exist(@foo._("bar/bar.iml"))
    end

    it "generate an IPR with the reference to correct module file" do
      File.should be_exist(@foo._("foo.ipr"))
      doc = xml_document(@foo._("foo.ipr"))
      doc.should have_nodes("#{xpath_to_module}", 2)
      module_ref = "$PROJECT_DIR$/foo.iml"
      doc.should have_nodes("#{xpath_to_module}[@fileurl='file://#{module_ref}', @filepath='#{module_ref}']", 1)
      module_ref = "$PROJECT_DIR$/bar/bar.iml"
      doc.should have_nodes("#{xpath_to_module}[@fileurl='file://#{module_ref}', @filepath='#{module_ref}']", 1)
    end
  end

  describe "with base_dir specified" do
    before do
      @foo = define "foo" do
        define('bar', :base_dir => 'fe') do
          define('baz', :base_dir => 'fi') do
            define('foe')
          end
          define('fum')
        end
      end
      invoke_generate_task
    end

    it "generates a subproject IML in the specified directory" do
      File.should be_exist(@foo._("fe/bar.iml"))
    end

    it "generates a sub-subproject IML in the specified directory" do
      File.should be_exist(@foo._("fi/baz.iml"))
    end

    it "generates a sub-sub-subproject IML that inherits the specified directory" do
      File.should be_exist(@foo._("fi/foe/foe.iml"))
    end

    it "generates a sub-subproject IML that inherits the specified directory" do
      File.should be_exist(@foo._("fe/fum/fum.iml"))
    end

    it "generate an IPR with the references to correct module files" do
      doc = xml_document(@foo._("foo.ipr"))
      doc.should have_nodes("#{xpath_to_module}", 5)
      ["foo.iml", "fe/bar.iml", "fi/baz.iml", "fi/foe/foe.iml","fe/fum/fum.iml"].each do |module_ref|
        doc.should have_nodes("#{xpath_to_module}[@fileurl='file://$PROJECT_DIR$/#{module_ref}', @filepath='$PROJECT_DIR$/#{module_ref}']", 1)
      end
    end
  end

  describe "with extensive intermodule dependencies" do
    before do
      mkdir_p 'foo/src/main/resources'
      mkdir_p 'foo/src/main/java/foo'
      touch 'foo/src/main/java/foo/Foo.java' # needed so that buildr will treat as a java project
      define "root" do
        repositories.remote << 'http://mirrors.ibiblio.org/pub/mirrors/maven2/'
        project.version = "2.5.2"
        define 'foo' do
          resources.from _(:source, :main, :resources)
          compile.with 'org.slf4j:slf4j-api:jar:1.5.11'
          test.using(:junit)
          package(:jar)
        end

        define 'bar' do
          # internally transitive dependencies on foo, both runtime and test
          compile.with project('root:foo'), project('root:foo').compile.dependencies
          test.using(:junit).with [project('root:foo').test.compile.target,
            project('root:foo').test.resources.target,
            project('root:foo').test.compile.dependencies].compact
          package(:jar)
        end
      end

      invoke_generate_task
      @bar_iml = xml_document(project('root:bar')._('bar.iml'))
      @bar_lib_urls = @bar_iml.get_elements("//orderEntry[@type='module-library']/library/CLASSES/root").collect do |root|
        root.attribute('url').to_s
      end
    end

    it "depends on the associated module exactly once" do
      @bar_iml.should have_nodes("//orderEntry[@type='module', @module-name='foo']", 1)
    end

    it "does not depend on the other project's packaged JAR" do
      @bar_lib_urls.grep(%r{#{project('root:foo').packages.first}}).should == []
    end

    it "does not depend on the the other project's target/classes directory" do
      @bar_lib_urls.grep(%r{foo/target/classes}).should == []
    end

    it "depends on the the other project's target/resources directory" do
      @bar_lib_urls.grep(%r{file://\$MODULE_DIR\$/../foo/target/resources}).size.should == 1
    end
  end
end
