# frozen_string_literal: true

require_relative "lib/loyalty_ref/version"

Gem::Specification.new do |spec|
  spec.name = "loyalty_ref"
  spec.version = LoyaltyRef::VERSION
  spec.authors = ["Kapil Pal"]
  spec.email = ["dev.kapildevpal@gmail.com"]

  spec.summary = "A flexible Ruby gem for building loyalty and referral systems in Rails apps"
  spec.description = "Add loyalty points, dynamic tier levels, and referral rewards to any Rails application with ease. Features include customizable earning rules, unique referral codes, built-in analytics, and an admin dashboard."
  spec.homepage = "https://github.com/rails_to_rescue/loyalty_ref"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.7.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir.glob("{app,config,db,lib}/**/*") + %w[README.md LICENSE.txt CHANGELOG.md]
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "rails", ">= 6.0.0"
  spec.add_dependency "activerecord", ">= 6.0.0"
  spec.add_dependency "actionview", ">= 6.0.0"
  spec.add_dependency "actionpack", ">= 6.0.0"
  spec.add_dependency "kaminari", "~> 1.2"

  spec.add_development_dependency "rspec-rails", "~> 6.0"
  spec.add_development_dependency "factory_bot_rails", "~> 6.0"
  spec.add_development_dependency "pry-byebug", "~> 3.9"
  spec.add_development_dependency "rubocop", "~> 1.0"
  spec.add_development_dependency "rubocop-rails", "~> 2.0"
end 