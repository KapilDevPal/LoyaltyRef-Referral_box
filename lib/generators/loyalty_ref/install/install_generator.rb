# frozen_string_literal: true

require "rails/generators"

module LoyaltyRef
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      def create_initializer
        template "initializer.rb", "config/initializers/loyalty_ref.rb"
      end

      def add_user_model_migration
        generate_migration = ask("Would you like to add referral_code and tier columns to your User model? (y/n)")
        
        if generate_migration.downcase == "y"
          generate "migration", "AddLoyaltyRefToUsers referral_code:string tier:string"
        end
      end

      def add_user_model_methods
        user_class = ask("What is your user model class name? (default: User)")
        user_class = "User" if user_class.blank?

        template "user_model.rb", "app/models/#{user_class.downcase}.rb", force: true
      end

      def show_instructions
        puts "\n" + "="*60
        puts "🎉 LoyaltyRef has been installed successfully!"
        puts "="*60
        puts "\nNext steps:"
        puts "1. Run: rails db:migrate"
        puts "2. Customize config/initializers/loyalty_ref.rb"
        puts "3. Access admin dashboard at: /loyalty"
        puts "\nFor more information, visit: https://github.com/rails_to_rescue/loyalty_ref"
        puts "="*60
      end
    end
  end
end 