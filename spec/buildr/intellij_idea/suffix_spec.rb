require File.expand_path('../../../spec_helper', __FILE__)

describe "iidea" do
  describe "Artifact generation with default suffix" do
    before do
      mkdir_p 'bar'

      @foo = define "foo" do
        define 'bar'
      end
      task('iidea').invoke
    end

    it "generates an IPR at the top level" do
      File.should be_exist(@foo._(root_project_filename("foo")))
    end

    it  "generates an IPR with correct module references" do
      module_file = @foo._(root_project_filename("foo"))
      results = File.read(module_file)
      results.should =~ /file:\/\/\$PROJECT_DIR\$\/foo-iidea\.iml/
      results.should =~ /file:\/\/\$PROJECT_DIR\$\/bar\/foo-bar-iidea\.iml/
    end

    it "generates an IML at the top level" do
      File.should be_exist(@foo._("foo-iidea.iml"))
    end

    it "generates an IML in subprojects" do
      File.should be_exist(@foo._("bar/foo-bar-iidea.iml"))
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
      results.should =~ /file:\/\/\$PROJECT_DIR\$\/foo\.iml/
      results.should =~ /file:\/\/\$PROJECT_DIR\$\/bar\/foo-bar\.iml/
    end

    it "generates an IML at the top level" do
      File.should be_exist(@foo._("foo.iml"))
    end

    it "generates an IML in subprojects" do
      File.should be_exist(@foo._("bar/foo-bar.iml"))
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
      results.should =~ /file:\/\/\$PROJECT_DIR\$\/foo-Y\.iml/
      results.should =~ /file:\/\/\$PROJECT_DIR\$\/bar\/foo-bar-Y\.iml/
    end

    it "generates an IML at the top level" do
      File.should be_exist(@foo._("foo-Y.iml"))
    end

    it "generates an IML in subprojects" do
      File.should be_exist(@foo._("bar/foo-bar-Y.iml"))
    end

  end

end
