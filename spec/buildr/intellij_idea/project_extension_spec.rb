require File.expand_path('../../../spec_helper', __FILE__)

describe "project extension" do
  it "provides an 'iidea:generate' task" do
    Rake::Task.tasks.detect{|task| task.to_s == "iidea:generate"}.should_not be_nil
  end

  it "documents the 'iidea:generate' task" do
    Rake::Task.tasks.detect{|task| task.to_s == "iidea:generate"}.comment.should_not be_nil
  end

  it "provides an 'iidea:clean' task" do
    Rake::Task.tasks.detect{|task| task.to_s == "iidea:clean"}.should_not be_nil
  end

  it "documents the 'iidea:clean' task" do
    Rake::Task.tasks.detect{|task| task.to_s == "iidea:clean"}.comment.should_not be_nil
  end

  it "removes the 'idea' task" do
    Rake::Task.tasks.detect{|task| task.to_s == "idea"}.should be_nil
  end

  it "removes the 'idea7x' task" do
    Rake::Task.tasks.detect{|task| task.to_s == "idea7x"}.should be_nil
  end

  it "removes the 'idea7x:clean' task" do
    Rake::Task.tasks.detect{|task| task.to_s == "idea7x:clean"}.should be_nil
  end
end
