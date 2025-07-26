# frozen_string_literal: true

module ReferralBox
  class Engine < ::Rails::Engine
    isolate_namespace ReferralBox

    config.generators do |g|
      g.test_framework :rspec
      g.fixture_replacement :factory_bot
      g.factory_bot dir: 'spec/factories'
    end

    initializer "referral_box.assets" do |app|
      app.config.assets.precompile += %w( referral_box.js )
    end

    initializer "referral_box.routes" do |app|
      app.routes.prepend do
        mount ReferralBox::Engine => ReferralBox.configuration.admin_route_path
      end
    end

    initializer "referral_box.migrations" do |app|
      unless app.root.to_s.match root.to_s
        config.paths["db/migrate"].expanded.each do |expanded_path|
          app.config.paths["db/migrate"] << expanded_path
        end
      end
    end
  end
end 