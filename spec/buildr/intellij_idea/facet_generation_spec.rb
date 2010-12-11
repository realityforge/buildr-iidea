require File.expand_path('../../../spec_helper', __FILE__)

describe "iidea:generate" do
  describe "with web and webservice facet added to root project" do
    before do
      @foo = define "foo" do
        iml.add_facet("Web", "web") do |facet|
          facet.configuration do |conf|
            conf.descriptors do |desc|
              desc.deploymentDescriptor :name => 'web.xml',
                                        :url => "file://$MODULE_DIR$/src/main/webapp/WEB-INF/web.xml",
                                        :optional => "false", :version => "2.4"
            end
            conf.webroots do |webroots|
              webroots.root :url => "file://$MODULE_DIR$/src/main/webapp", :relative => "/"
            end
          end
        end
        iml.add_facet("WebServices Client", "WebServicesClient") do |facet|
          facet.configuration "ws.engine" => "Glassfish / JAX-WS 2.X RI / Metro 1.X / JWSDP 2.0"
        end
        define 'bar'
      end
      invoke_generate_task
    end

    it "generates an IML for root project with a web and webservice facet" do
      doc = xml_document(@foo._("foo.iml"))
      facet_xpath = "/module/component[@name='FacetManager']/facet"
      doc.should have_nodes(facet_xpath, 2)
      doc.should have_xpath("#{facet_xpath}[@type='web', @name='Web']")
      doc.should have_xpath("#{facet_xpath}[@type='WebServicesClient', @name='WebServices Client']")
    end
  end
end
