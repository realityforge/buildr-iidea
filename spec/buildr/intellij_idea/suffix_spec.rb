require File.expand_path('../../../spec_helper', __FILE__)

describe "iidea" do
  describe "Artifact generation with default suffix" do
    before do
      mkdir_p 'bar'
      mkdir_p 'baz'

      @foo = define "foo" do
        define 'bar'
        define 'baz'
      end
      task('iidea').invoke
    end

    it "generates an IPR at the top level" do
      File.should be_exist(@foo._("foo-iidea.ipr"))
    end

    it  "generates an IPR with correct module references" do
      module_file = @foo._("foo-iidea.ipr")
      results = File.read(module_file)
      results.should =~ /file:\/\/\$PROJECT_DIR\$\/foo-iidea\.iml/
      results.should =~ /file:\/\/\$PROJECT_DIR\$\/bar\/foo-bar-iidea\.iml/
      results.should =~ /file:\/\/\$PROJECT_DIR\$\/baz\/foo-baz-iidea\.iml/
    end

    it "generates an IML at the top level" do
      File.should be_exist(@foo._("foo-iidea.iml"))
    end

    it "generates an IML in subprojects" do
      File.should be_exist(@foo._("bar/foo-bar-iidea.iml"))
      File.should be_exist(@foo._("baz/foo-baz-iidea.iml"))
    end
  end

  describe "IPR generation with empty suffix" do
    before do
      Buildr::IntellijIdea::Config.suffix = ''
      mkdir_p 'bar'
      mkdir_p 'baz'

      @foo = define "foo" do
        define 'bar'
        define 'baz'
      end
      task('iidea').invoke
    end

    after do
      Buildr::IntellijIdea::Config.suffix = Buildr::IntellijIdea::Config::DEFAULT_SUFFIX
    end

    it "generates an IPR at the top level" do
      File.should be_exist(@foo._("foo.ipr"))
    end

    it  "generates an IPR with correct module references" do
      module_file = @foo._("foo.ipr")
      results = File.read(module_file)
      results.should =~ /file:\/\/\$PROJECT_DIR\$\/foo\.iml/
      results.should =~ /file:\/\/\$PROJECT_DIR\$\/bar\/foo-bar\.iml/
      results.should =~ /file:\/\/\$PROJECT_DIR\$\/baz\/foo-baz\.iml/
    end

    it "generates an IML at the top level" do
      File.should be_exist(@foo._("foo.iml"))
    end

    it "generates an IML in subprojects" do
      File.should be_exist(@foo._("bar/foo-bar.iml"))
      File.should be_exist(@foo._("baz/foo-baz.iml"))
    end

  end
end