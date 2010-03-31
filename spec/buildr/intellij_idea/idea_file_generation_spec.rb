require File.expand_path('../../../spec_helper', __FILE__)

MODULE_ENTRY_XPATH = "/project/component[@name='ProjectModuleManager']/modules/module"

describe "generate task" do
  describe "with a single project definition" do
    describe "and default naming" do
      before do
        @foo = define "foo"
        task('iidea').invoke
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
        doc.should have_nodes("#{MODULE_ENTRY_XPATH}[@fileurl='file://#{module_ref}', @filepath='#{module_ref}']", 1)
      end
    end

    describe "and id overrides" do
      before do
        @foo = define "foo" do
          ipr.id = 'fooble'
          iml.id = 'feap'
        end
        task('iidea').invoke
      end

      it "generate an IPR in the root directory" do
        File.should be_exist(@foo._("fooble.ipr"))
      end

      it "generates an IML in the root directory" do
        File.should be_exist(@foo._("feap.iml"))
      end

      it "generate an IPR with the reference to correct module file" do
        File.should be_exist(@foo._("fooble.ipr"))
        doc = xml_document(@foo._("fooble.ipr"))
        module_ref = "$PROJECT_DIR$/feap.iml"
        doc.should have_nodes("#{MODULE_ENTRY_XPATH}[@fileurl='file://#{module_ref}', @filepath='#{module_ref}']", 1)
      end
    end

    describe "and a suffix defined" do
      before do
        @foo = define "foo" do
          ipr.suffix = '-ipr-suffix'
          iml.suffix = '-iml-suffix'
        end
        task('iidea').invoke
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
        doc.should have_nodes("#{MODULE_ENTRY_XPATH}", 1)
        module_ref = "$PROJECT_DIR$/foo-iml-suffix.iml"
        doc.should have_nodes("#{MODULE_ENTRY_XPATH}[@fileurl='file://#{module_ref}', @filepath='#{module_ref}']", 1)
      end
    end
  end

  describe "with a subproject" do
    before do
      @foo = define "foo" do
        define 'bar'
      end
      task('iidea').invoke
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
      doc.should have_nodes("#{MODULE_ENTRY_XPATH}", 2)
      module_ref = "$PROJECT_DIR$/foo.iml"
      doc.should have_nodes("#{MODULE_ENTRY_XPATH}[@fileurl='file://#{module_ref}', @filepath='#{module_ref}']", 1)
      module_ref = "$PROJECT_DIR$/bar/bar.iml"
      doc.should have_nodes("#{MODULE_ENTRY_XPATH}[@fileurl='file://#{module_ref}', @filepath='#{module_ref}']", 1)
    end
  end
end