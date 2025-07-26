# frozen_string_literal: true

require "rails/generators"

module ReferralBox
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      def create_initializer
        template "initializer.rb", "config/initializers/referral_box.rb"
      end

      def add_user_model_migration
        generate_migration = ask("Would you like to add referral_code and tier columns to your User model? (y/n)")
        
        if generate_migration.downcase == 'y'
          generate "migration", "AddReferralBoxToUsers referral_code:string tier:string referrer:references"
          puts "Migration generated! Run 'rails db:migrate' to apply it."
        end
      end

      def add_user_model_methods
        user_class = ask("What is your user model class name? (default: User)")
        user_class = "User" if user_class.blank?
        
        template "user_model.rb", "app/models/#{user_class.downcase}.rb", skip: true
        puts "Please add the ReferralBox methods to your #{user_class} model manually."
      end

      def show_instructions
        puts "\n" + "="*60
        puts "ReferralBox Installation Complete!"
        puts "="*60
        puts "\nNext steps:"
        puts "1. Run 'rails db:migrate' to create the database tables"
        puts "2. Add ReferralBox methods to your User model (see template)"
        puts "3. Configure ReferralBox in config/initializers/referral_box.rb"
        puts "4. Visit /referral_box to access the admin dashboard"
        puts "\nFor more information, see the documentation!"
        puts "="*60
      end
    end
  end
end 