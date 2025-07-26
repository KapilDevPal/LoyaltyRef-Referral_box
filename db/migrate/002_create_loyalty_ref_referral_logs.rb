# frozen_string_literal: true

class CreateLoyaltyRefReferralLogs < ActiveRecord::Migration[7.0]
  def change
    create_table :loyalty_ref_referral_logs do |t|
      t.string :referral_code, null: false
      t.references :referee, polymorphic: true, null: true
      t.string :user_agent
      t.string :ip_address
      t.string :referrer
      t.datetime :clicked_at, null: false
      t.datetime :signed_up_at
      t.string :device_type
      t.string :browser
      t.json :geo_data
      t.json :device_data

      t.timestamps
    end

    add_index :loyalty_ref_referral_logs, :referral_code
    add_index :loyalty_ref_referral_logs, :clicked_at
    add_index :loyalty_ref_referral_logs, :signed_up_at
    add_index :loyalty_ref_referral_logs, :ip_address
    add_index :loyalty_ref_referral_logs, :device_type
    add_index :loyalty_ref_referral_logs, :browser
  end
end 