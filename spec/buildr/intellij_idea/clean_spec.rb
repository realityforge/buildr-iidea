require File.expand_path('../../../spec_helper', __FILE__)

describe "iidea:clean" do
  before do
    write "foo.ipr"
    write "foo.iml"
    write "other.ipr"
    write "other.iml"
    mkdir_p 'bar'
    write "bar/bar.iml"
    write "bar/other.ipr"
    write "bar/other.iml"

    @foo = define "foo" do
      define "bar"
    end
    invoke_clean_task
  end

  it "should remove the ipr file" do
    File.exists?("foo.ipr").should be_false
  end

  it "should remove the project iml file" do
    File.exists?("foo.iml").should be_false
  end

  it "should remove the subproject iml file" do
    File.exists?("foo.iml").should be_false
  end

  it "should not remove other iml and ipr files" do
    File.exists?("other.ipr").should be_true
    File.exists?("other.iml").should be_true
    File.exists?("bar/other.ipr").should be_true
    File.exists?("bar/other.iml").should be_true
  end
end