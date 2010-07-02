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

  describe "#no_iml" do
    it "makes #iml? false" do
      @foo = define "foo" do
        project.no_iml
      end
      @foo.iml?.should be_false
    end
  end

  describe "#iml" do
    before do
      define "foo" do
        iml.suffix = "-top"

        define "bar" do
          iml.suffix = "-mid"

          define "baz" do
          end
        end
      end
    end

    it "inherits the direct parent's IML settings" do
      project('foo:bar:baz').iml.suffix.should == "-mid"
    end

    it "does not modify the parent's IML settings" do
      project('foo').iml.suffix.should == "-top"
    end

    it "works even when the parent has no IML" do
      lambda {
        define "a" do
          project.no_iml
          define "b" do
            iml.suffix = "-alone"
          end
        end
      }.should_not raise_error
    end

    it "inherits from the first ancestor which has an IML" do
      define "a" do
        iml.suffix = "-a"
        define "b" do
          iml.suffix = "-b"
          define "c" do
            project.no_iml
            define "d" do
              project.no_iml
              define "e" do
                project.no_iml
                define "f" do
                end
              end
            end
          end
        end
      end

      project("a:b:c:d:e:f").iml.suffix.should == "-b"
    end
  end
end
