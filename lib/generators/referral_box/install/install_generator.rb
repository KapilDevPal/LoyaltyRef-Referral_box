# frozen_string_literal: true

require "rails/generators"

module ReferralBox
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      def create_initializer
        template "initializer.rb", "config/initializers/referral_box.rb"
      end

      def ask_for_model_name
        puts "\n" + "="*60
        puts "ReferralBox Model Configuration"
        puts "="*60
        
        # Detect existing models
        model_files = Dir.glob("app/models/*.rb")
        existing_models = model_files.map { |f| File.basename(f, '.rb').classify }
        
        if existing_models.any?
          puts "\nExisting models found: #{existing_models.join(', ')}"
        end
        
        @model_class = ask("What is your user model class name? (e.g., User, Customer, Account, Member):", default: "User")
        
        # Confirm the choice
        puts "\nYou selected: #{@model_class}"
        confirm = ask("Is this correct? (y/n):", default: "y")
        
        unless confirm.downcase.start_with?('y')
          puts "Please run the generator again with the correct model name."
          exit
        end
        
        # Update the initializer with the selected model
        update_initializer_with_model(@model_class)
      end

      def add_model_migration
        if @model_class.present?
          generate_migration = "AddReferralBoxTo#{@model_class.pluralize}"
          migration_content = generate_migration_content(@model_class)
          
          create_file "db/migrate/#{Time.current.strftime('%Y%m%d%H%M%S')}_#{generate_migration.underscore}.rb", migration_content
          
          puts "\nMigration generated for #{@model_class} model!"
          puts "Run 'rails db:migrate' to apply it."
        else
          puts "Warning: Could not determine model class name."
          puts "Please manually create migration for your model."
        end
      end

      def add_model_methods
        if @model_class.present?
          model_file = "app/models/#{@model_class.underscore}.rb"
          
          if File.exist?(model_file)
            content = File.read(model_file)
            
            # Check if methods already exist
            if content.include?('has_many :referral_box_transactions')
              puts "ReferralBox methods already exist in #{@model_class} model."
            else
              # Try to inject after the class definition
              if content.match(/class #{@model_class}\s+<\s+ApplicationRecord/)
                inject_into_file model_file, after: "class #{@model_class} < ApplicationRecord" do
                  "\n  " + generate_model_methods(@model_class)
                end
                puts "Added ReferralBox methods to #{@model_class} model."
              elsif content.match(/class #{@model_class}\s+<\s+ActiveRecord::Base/)
                inject_into_file model_file, after: "class #{@model_class} < ActiveRecord::Base" do
                  "\n  " + generate_model_methods(@model_class)
                end
                puts "Added ReferralBox methods to #{@model_class} model."
              else
                # If we can't find the class definition, show manual instructions
                show_manual_model_instructions(@model_class)
              end
            end
          else
            show_manual_model_instructions(@model_class)
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

      def show_manual_model_instructions(model_class)
        puts "\n" + "="*60
        puts "Manual Model Setup Required"
        puts "="*60
        puts "\nPlease manually add the following methods to your #{model_class} model:"
        puts "\nFile: app/models/#{model_class.underscore}.rb"
        puts "\nAdd this inside your #{model_class} class:"
        puts "\n" + generate_model_methods(model_class)
        puts "\n" + "="*60
      end

      def update_initializer_with_model(model_class)
        initializer_path = "config/initializers/referral_box.rb"
        
        if File.exist?(initializer_path)
          content = File.read(initializer_path)
          updated_content = content.gsub(
            /config\.reference_class_name\s*=\s*['"][^'"]*['"]/,
            "config.reference_class_name = '#{model_class}'"
          )
          
          File.write(initializer_path, updated_content)
          puts "Updated initializer with #{model_class} model."
        end
      end

      def generate_migration_content(model_class)
        <<~MIGRATION
          # frozen_string_literal: true

          class AddReferralBoxTo#{model_class.pluralize} < ActiveRecord::Migration[#{get_rails_version}]
            def change
              # Add referral_code column if it doesn't exist
              unless column_exists?(:#{model_class.underscore.pluralize}, :referral_code)
                add_column :#{model_class.underscore.pluralize}, :referral_code, :string
              end
              
              # Add tier column if it doesn't exist
              unless column_exists?(:#{model_class.underscore.pluralize}, :tier)
                add_column :#{model_class.underscore.pluralize}, :tier, :string
              end
              
              # Add referrer reference if it doesn't exist
              unless column_exists?(:#{model_class.underscore.pluralize}, :referrer_id)
                add_reference :#{model_class.underscore.pluralize}, :referrer, null: true, foreign_key: { to_table: :#{model_class.underscore.pluralize} }
              end
              
              # Add unique index on referral_code if it doesn't exist
              unless index_exists?(:#{model_class.underscore.pluralize}, :referral_code)
                add_index :#{model_class.underscore.pluralize}, :referral_code, unique: true
              end
            end
          end
        MIGRATION
      end

      def get_rails_version
        # Get the major and minor version (e.g., "8.0" for Rails 8.0.x)
        major = Rails.version.split('.').first
        minor = Rails.version.split('.').second || '0'
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