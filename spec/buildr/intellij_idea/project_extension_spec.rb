require File.expand_path('../../../spec_helper', __FILE__)

describe "project extension" do
  it "provides an 'iidea' task" do
    Rake::Task.tasks.detect{|task| task.to_s == "iidea"}.should_not be_nil
  end

  it "document 'iidea' task" do
    Rake::Task.tasks.detect{|task| task.to_s == "iidea"}.comment.should_not be_nil
  end

  it "provides an 'iidea:clean' task" do
    Rake::Task.tasks.detect{|task| task.to_s == "iidea:clean"}.should_not be_nil
  end

  it "document 'iidea:clean' task" do
    Rake::Task.tasks.detect{|task| task.to_s == "iidea:clean"}.comment.should_not be_nil
  end
end
