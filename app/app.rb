class App < Sinatra::Base
  configure do
    register Barista::Integration::Sinatra
    set :public_folder, 'public'
    set :views, File.join(Config.root, '/assets/slim/')
  end

  def include_slim(name, options = {}, &block)
    Slim::Template.new(File.join(settings.views, "#{name}.slim"), options).render(self, &block)
  end

  get "/" do
    redirect to('/charts')
  end

  get "/charts" do
    slim :charts, layout: :layout
  end
end
