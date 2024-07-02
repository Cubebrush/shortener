module Shortener
  class Railtie < ::Rails::Railtie
    initializer "shortener.register.active.record.extension" do |app|
      require_relative '../../app/middlewares/shortener_redirect_middleware'
      app.config.middleware.use ShortenerRedirectMiddleware

      ActiveSupport.on_load :active_record do
        extend Shortener::ActiveRecordExtension
      end
    end
  end
end
