module Buildr
  module IntellijIdea
    # Abstract base class for IdeaModule and IdeaProject
    class IdeaFile
      DEFAULT_SUFFIX = ""

      attr_reader :buildr_project
      attr_writer :suffix
      attr_writer :id
      attr_accessor :template

      def suffix
        @suffix ||= DEFAULT_SUFFIX
      end

      def filename
        buildr_project.path_to("#{name}.#{extension}")
      end

      def id
        @id ||= buildr_project.name.split(':').last
      end

      def add_component(name, attrs = {}, &xml)
        self.components << create_component(name, attrs, &xml)
      end

      def write(f)
        document.write f
      end

      protected

      def name
        "#{self.id}#{suffix}"
      end

      def create_component(name, attrs = {})
        target = StringIO.new
        Builder::XmlMarkup.new(:target => target, :indent => 2).component(attrs.merge({ :name => name })) do |xml|
          yield xml if block_given?
        end
        REXML::Document.new(target.string).root
      end

      def components
        @components ||= self.default_components
      end

      def load_document(filename)
        REXML::Document.new(File.read(filename))
      end

      def document
        doc = (File.exist?(self.filename)) ? load_document(self.filename) : base_document 
        if self.template
          template_doc = load_document(self.template)
          REXML::XPath.each(template_doc, "//component") do |element|
            inject_component(doc, element)
          end
        end
        self.components.each do |comp_elt|
          # execute deferred components
          comp_elt = comp_elt.call if Proc === comp_elt
          inject_component(doc, comp_elt) if comp_elt
        end
        doc
      end

      # replace overridden component (if any) with specified component
      def inject_component(doc, component)
        doc.root.delete_element("//component[@name='#{component.attributes['name']}']")
        doc.root.add_element component
      end
    end
  end
end