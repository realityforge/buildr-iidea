module Buildr
  module IntellijIdea
    class Util
      # Convert the given absolute path into a path
      # relative to the second given absolute path.
      def self.relativepath(abspath, relativeto)
        path = abspath.split(File::SEPARATOR)
        rel = relativeto.split(File::SEPARATOR)
        while (path.length > 0) && (path.first == rel.first)
          path.shift
          rel.shift
        end
        ('..' + File::SEPARATOR) * (rel.length - 1) + path.join(File::SEPARATOR)
      end
    end
  end
end