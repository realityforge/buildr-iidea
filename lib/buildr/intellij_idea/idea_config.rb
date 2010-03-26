module Buildr
  module IntellijIdea
    class Config
      DEFAULT_SUFFIX = "-iidea"
      @@suffix = DEFAULT_SUFFIX unless defined? @@suffix

      def self.suffix
        @@suffix
      end

      def self.suffix=(suffix)
        @@suffix = suffix
      end

      @@absolute_path_for_local_repository = false unless defined? @@absolute_path_for_local_repository

      def self.absolute_path_for_local_repository?
        @@absolute_path_for_local_repository
      end

      def self.absolute_path_for_local_repository=(absolute_path_for_local_repository)
        @@absolute_path_for_local_repository = absolute_path_for_local_repository
      end


    end
  end
end