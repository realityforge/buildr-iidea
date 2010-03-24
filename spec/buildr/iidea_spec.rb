require File.expand_path('../../spec_helper', __FILE__)

# TODO: these specs are laughably incomplete

describe "iidea" do
  it "provides an 'iidea' task'" do
    Rake::Task.tasks.collect(&:to_s).should include("iidea")
  end

  it "provides an 'iidea:clean' task'" do
    Rake::Task.tasks.collect(&:to_s).should include("iidea:clean")
  end

  describe "documentation" do
    before do
      define 'any'
    end

    it "describes iidea" do
      task('iidea').comment.should == "Generate Intellij IDEA artifacts for all projects"
    end

    it "describes iidea:clean" do
      task('iidea:clean').comment.should == "Delete the generated Intellij IDEA artifacts"
    end
  end

  describe "IPR generation" do
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
      File.exist?(@foo._("foo-iidea.ipr")).should be_true
    end

    it "only generates one IPR" do
      Dir[@foo._("**/*.ipr")].should have(1).entry
    end

    it "informs the user about what it's doing" do
      $messages[:info].should include("Writing #{@foo._('foo-iidea.ipr')}")
    end
  end
end
