require File.expand_path('../../../spec_helper', __FILE__)

describe "Buildr::IntellijIdea::IdeaModule" do
  before do
    @foo = define "foo"
  end

  it "has correct default iml.type setting" do
    @foo.iml.type.should == "JAVA_MODULE"
  end

  it "has correct default iml.local_repository_env_override setting" do
    @foo.iml.local_repository_env_override.should == "MAVEN_REPOSITORY"
  end
end
