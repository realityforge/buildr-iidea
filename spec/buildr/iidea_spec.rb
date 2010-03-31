require File.expand_path('../../spec_helper', __FILE__)

# TODO: these specs are laughably incomplete

describe "iidea" do
  describe "IPR generation" do
    before do
      mkdir_p 'bar'

      @foo = define "foo" do
        define 'bar'
        define 'baz'
      end
      task('iidea').invoke
    end

    it "generates an IPR at the top level" do
      File.exist?(root_project_filename(@foo)).should be_true
    end

    it "only generates one IPR" do
      Dir[@foo._("**/*.ipr")].should have(1).entry
    end

    it "informs the user about what it's doing" do
      $messages[:info].should include("Writing #{root_project_filename(@foo)}")
    end
  end
end
