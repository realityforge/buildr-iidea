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

    it "informs the user about what it's doing" do
      $messages[:info].should include("Writing #{root_project_filename(@foo)}")
    end
  end
end
