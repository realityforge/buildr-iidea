require File.expand_path('../../../spec_helper', __FILE__)

describe "iidea" do
  describe "artifact generation with default suffix" do
    before do
      mkdir_p 'bar'

      @foo = define "foo" do
        define 'bar'
      end
      task('iidea').invoke
    end

    it "generates an IPR at the top level" do
      File.should be_exist(root_project_filename(@foo))
    end

    it  "generates an IPR with correct module references" do
      module_file = root_project_filename(@foo)
      results = File.read(module_file)
      results.include?('file://$PROJECT_DIR$/foo-iidea.iml').should be_true
      results.include?('file://$PROJECT_DIR$/bar/bar-iidea.iml').should be_true
    end

    it "generates an IML at the top level" do
      File.should be_exist(@foo._("foo-iidea.iml"))
    end

    it "generates an IML in subprojects" do
      File.should be_exist(@foo._("bar/bar-iidea.iml"))
    end
  end

  describe "IPR generation with empty suffix" do
    before do
      mkdir_p 'bar'

      @foo = define "foo" do
        ipr.suffix = ''
        iml.suffix = ''
        define 'bar'
      end
      task('iidea').invoke
    end

    it "generates an IPR at the top level" do
      File.should be_exist(@foo._("foo.ipr"))
    end

    it  "generates an IPR with correct module references" do
      module_file = @foo._("foo.ipr")
      results = File.read(module_file)
      results.include?('file://$PROJECT_DIR$/foo.iml').should be_true
      results.include?('file://$PROJECT_DIR$/bar/bar.iml').should be_true
    end

    it "generates an IML at the top level" do
      File.should be_exist(@foo._("foo.iml"))
    end

    it "generates an IML in subprojects" do
      File.should be_exist(@foo._("bar/bar.iml"))
    end

  end

  describe "IPR generation with specific suffix" do
    before do
      mkdir_p 'bar'

      @foo = define "foo" do
        ipr.suffix = '-X'
        iml.suffix = '-Y'
        define 'bar'
      end
      task('iidea').invoke
    end

    it "generates an IPR at the top level" do
      File.should be_exist(@foo._("foo-X.ipr"))
    end

    it  "generates an IPR with correct module references" do
      module_file = @foo._("foo-X.ipr")
      results = File.read(module_file)
      results.include?('file://$PROJECT_DIR$/foo-Y.iml').should be_true
      results.include?('file://$PROJECT_DIR$/bar/bar-Y.iml').should be_true
    end

    it "generates an IML at the top level" do
      File.should be_exist(@foo._("foo-Y.iml"))
    end

    it "generates an IML in subprojects" do
      File.should be_exist(@foo._("bar/bar-Y.iml"))
    end

  end

  describe "IPR generation with id values specified" do
    before do
      @foo = define "foo" do
        ipr.id = "foosome"
        ipr.suffix = ""
        iml.id = "fooish"
        iml.suffix = ""
      end
      task('iidea').invoke
    end

    it "generates an IPR at the top level" do
      File.should be_exist(@foo._("foosome.ipr"))
    end

    it  "generates an IPR with correct module references" do
      module_file = @foo._("foosome.ipr")
      results = File.read(module_file)
      results.include?('file://$PROJECT_DIR$/fooish.iml').should be_true
    end

    it "generates an IML at the top level" do
      File.should be_exist(@foo._("fooish.iml"))
    end
  end

end
