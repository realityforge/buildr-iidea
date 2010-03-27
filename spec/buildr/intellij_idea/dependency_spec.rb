require File.expand_path('../../../spec_helper', __FILE__)

describe "iidea" do
  describe "IdeaModule.local_repository_env_override" do
    describe "uses M2_REPO by default" do
      before do
        artifact('group:id:jar:1.0') { |t| write t.to_s }

        @foo = define "foo" do
          compile.with 'group:id:jar:1.0'
        end
        task('iidea').invoke
      end

      it "generates IML with a dependency" do
        module_file = root_module_filename(@foo)
        File.should be_exist(module_file)
        File.read(module_file).should =~ /jar:\/\/\$M2_REPO\$\/group\/id\/1\.0\/id-1\.0\.jar\!\//
      end
    end

    describe "uses absolute paths when nil specified" do
      before do
        artifact('group:id:jar:1.0') { |t| write t.to_s }

        @foo = define "foo" do
          iml.local_repository_env_override = nil
          compile.with 'group:id:jar:1.0'
        end
        task('iidea').invoke
      end

      it "generates IML with a dependency" do
        module_file = root_module_filename(@foo)
        File.should be_exist(module_file)
        File.read(module_file).should_not =~ /\$M2_REPO\$/
      end
    end


    describe "uses MAVEN_REPOSITORY in paths when specified" do
      before do
        artifact('group:id:jar:1.0') { |t| write t.to_s }

        @foo = define "foo" do
          iml.local_repository_env_override = "MAVEN_REPOSITORY"
          compile.with 'group:id:jar:1.0'
        end
        task('iidea').invoke
      end

      it "generates IML with a dependency" do
        module_file = root_module_filename(@foo)
        File.should be_exist(module_file)
        File.read(module_file).should =~ /\$MAVEN_REPOSITORY\$/
        File.read(module_file).should_not =~ /\$M2_REPO\$/
      end
    end

  end
end
