# frozen_string_literal: true

require "rails/engine"

module LoyaltyRef
  class Engine < ::Rails::Engine
    isolate_namespace LoyaltyRef

    config.generators do |g|
      g.test_framework :rspec, fixture: false
      g.fixture_replacement :factory_bot, dir: "spec/factories"
      g.assets false
      g.helper false
    end

    initializer "loyalty_ref.assets" do |app|
      app.config.assets.precompile += %w[loyalty_ref_manifest.js]
    end

    initializer "loyalty_ref.routes" do |app|
      app.routes.prepend do
        mount LoyaltyRef::Engine => LoyaltyRef.configuration.admin_route_path
      end
    end

    initializer "loyalty_ref.migrations" do |app|
      unless app.root.to_s.match root.to_s
        config.paths["db/migrate"].expanded.each do |expanded_path|
          app.config.paths["db/migrate"] << expanded_path
        end
      end
    end
  end
end 