require File.expand_path('../../../spec_helper', __FILE__)

describe "IntellijIdea:IdeaModule" do
  describe "with local_repository_env_override = nil" do
    describe "base_directory on different drive on windows" do
      before do
        @foo = define "foo", :base_dir => "C:/bar" do
          iml.local_repository_env_override = nil
        end
      end

      it "generates relative paths correctly" do
        @foo.iml.send(:resolve_path, "E:/foo").should eql('E:/foo')
      end
    end

    describe "base_directory on same drive on windows" do
      before do
        @foo = define "foo", :base_dir => "C:/bar" do
          iml.local_repository_env_override = nil
        end
      end

      it "generates relative paths correctly" do
        @foo.iml.send(:resolve_path, "C:/foo").should eql('$MODULE_DIR$/../foo')
      end
    end

  end
end
