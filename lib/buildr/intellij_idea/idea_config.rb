module Buildr
  module IntellijIdea
    class Config
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