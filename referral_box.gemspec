# frozen_string_literal: true

require_relative "lib/referral_box/version"

Gem::Specification.new do |spec|
  spec.name = "referral_box"
  spec.version = ReferralBox::VERSION
  spec.authors = ["Kapil Dev Pal"]
  spec.email = ["dev.kapildevpal@gmail.com"]

  spec.summary = "A flexible Ruby gem for building loyalty and referral systems in Rails apps"
  spec.description = "Add loyalty points, dynamic tier levels, and referral rewards to any Rails application with ease. Features include customizable earning rules, unique referral codes, built-in analytics, and an admin dashboard."
  spec.homepage = "https://github.com/KapilDevPal/referral_box"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.7.0"

  spec.metadata["source_code_uri"] = "https://github.com/KapilDevPal/referral_box"
  spec.metadata["changelog_uri"] = "https://github.com/KapilDevPal/referral_box/blob/main/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir.glob("{app,config,db,lib}/**/*") + %w[README.md LICENSE.txt CHANGELOG.md logo.jpg]
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # ✅ Support Rails 6.0 and above (no upper limit)
  spec.add_runtime_dependency "rails", ">= 6.0"
  spec.add_runtime_dependency "activerecord", ">= 6.0"
  spec.add_runtime_dependency "actionview", ">= 6.0"
  spec.add_runtime_dependency "actionpack", ">= 6.0"
  spec.add_runtime_dependency "kaminari", "~> 1.2"

  spec.add_development_dependency "rspec-rails", "~> 5.0"
  spec.add_development_dependency "factory_bot_rails", "~> 6.0"
  spec.add_development_dependency "pry-byebug", "~> 3.9"
  spec.add_development_dependency "rubocop", "~> 1.0"
  spec.add_development_dependency "rubocop-rails", "~> 2.0"
end
