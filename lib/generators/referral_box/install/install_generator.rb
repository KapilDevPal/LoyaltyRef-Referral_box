# frozen_string_literal: true

require "rails/generators"

module ReferralBox
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      def create_initializer
        template "initializer.rb", "config/initializers/referral_box.rb"
      end

      def add_model_migration
        # Read the configuration to determine the model class name
        model_class = get_model_class_name
        
        if model_class.present?
          generate_migration = "AddReferralBoxTo#{model_class.pluralize}"
          migration_content = generate_migration_content(model_class)
          
          create_file "db/migrate/#{Time.current.strftime('%Y%m%d%H%M%S')}_#{generate_migration.underscore}.rb", migration_content
          
          puts "Migration generated for #{model_class} model!"
          puts "Run 'rails db:migrate' to apply it."
        else
          puts "Warning: Could not determine model class name from configuration."
          puts "Please manually create migration for your model."
        end
      end

      def add_model_methods
        model_class = get_model_class_name
        
        if model_class.present?
          model_file = "app/models/#{model_class.underscore}.rb"
          
          if File.exist?(model_file)
            inject_into_file model_file, after: "class #{model_class} < ApplicationRecord" do
              "\n  " + generate_model_methods(model_class)
            end
            puts "Added ReferralBox methods to #{model_class} model."
          else
            puts "Warning: #{model_file} not found. Please manually add ReferralBox methods to your #{model_class} model."
          end
        end
      end

      def show_instructions
        puts "\n" + "="*60
        puts "ReferralBox Installation Complete!"
        puts "="*60
        puts "\nNext steps:"
        puts "1. Run 'rails db:migrate' to create the database tables"
        puts "2. Configure ReferralBox in config/initializers/referral_box.rb"
        puts "3. Visit /referral_box to access the admin dashboard"
        puts "\nFor more information, see the documentation!"
        puts "="*60
      end

      private

      def get_model_class_name
        # Try to read from existing initializer first
        initializer_path = "config/initializers/referral_box.rb"
        
        if File.exist?(initializer_path)
          content = File.read(initializer_path)
          if match = content.match(/config\.reference_class_name\s*=\s*['"]([^'"]+)['"]/)
            return match[1]
          end
        end
        
        # Default to 'User' if not found
        'User'
      end

      def generate_migration_content(model_class)
        <<~MIGRATION
          # frozen_string_literal: true

          class AddReferralBoxTo#{model_class.pluralize} < ActiveRecord::Migration[#{get_rails_version}]
            def change
              add_column :#{model_class.underscore.pluralize}, :referral_code, :string
              add_column :#{model_class.underscore.pluralize}, :tier, :string
              add_reference :#{model_class.underscore.pluralize}, :referrer, null: true, foreign_key: { to_table: :#{model_class.underscore.pluralize} }
              
              add_index :#{model_class.underscore.pluralize}, :referral_code, unique: true
            end
          end
        MIGRATION
      end

      def get_rails_version
        # Get the major and minor version (e.g., "8.0" instead of just "8")
        major, minor = Rails.version.split('.')[0..1]
        "#{major}.#{minor}"
      end

      def generate_model_methods(model_class)
        <<~METHODS
          has_many :referral_box_transactions, class_name: 'ReferralBox::Transaction', as: :user
          has_many :referrals, class_name: '#{model_class}', foreign_key: 'referrer_id'
          belongs_to :referrer, class_name: '#{model_class}', optional: true

          before_create :generate_referral_code

          def points_balance
            ReferralBox.balance(self)
          end

          def current_tier
            ReferralBox.tier(self)
          end

          def referral_link
            "\#{Rails.application.routes.url_helpers.root_url}?ref=\#{referral_code}"
          end

          private

          def generate_referral_code
            return if referral_code.present?

            loop do
              self.referral_code = SecureRandom.alphanumeric(ReferralBox.configuration.referral_code_length).upcase
              break unless #{model_class}.exists?(referral_code: referral_code)
            end
          end
        METHODS
      end
    end
  end
end 