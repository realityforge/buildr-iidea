require File.expand_path('../../../spec_helper', __FILE__)

describe "iidea" do
  describe "Dependency uses M2_REPO by default" do
    before do
      artifact('group:id:jar:1.0') { |t| write t.to_s }

      @foo = define "foo" do
        compile.with 'group:id:jar:1.0'
      end
      task('iidea').invoke
    end

    it "generates IML with a dependency" do
      module_file = @foo._("foo#{Buildr::IntellijIdea::Config.suffix}.iml")
      File.should be_exist(module_file)
      File.read(module_file).should =~ /jar:\/\/\$M2_REPO\$\/group\/id\/1\.0\/id-1\.0\.jar\!\//
    end
  end

  describe "Dependency uses absolute paths for dependencies in local repo when specified" do
    before do
      Buildr::IntellijIdea::Config.absolute_path_for_local_repository = true

      artifact('group:id:jar:1.0') { |t| write t.to_s }

      @foo = define "foo" do
        compile.with 'group:id:jar:1.0'
      end
      task('iidea').invoke
    end

    after do
      Buildr::IntellijIdea::Config.absolute_path_for_local_repository = false
    end

    it "generates IML with a dependency" do
      module_file = @foo._("foo#{Buildr::IntellijIdea::Config.suffix}.iml")
      File.should be_exist(module_file)
      File.read(module_file).should_not =~ /\$M2_REPO\$/
    end
  end
end
