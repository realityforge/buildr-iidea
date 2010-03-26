module Buildr
  module IntellijIdea
    class Config
      @@suffix = "-iidea" unless defined? @@suffix

      def self.suffix
        @@suffix
      end

      def self.suffix=(suffix)
        @@suffix = suffix
      end
    end
  end
end