# frozen_string_literal: true

class CreateReferralBoxTransactions < ActiveRecord::Migration[7.0]
  def change
    create_table :referral_box_transactions do |t|
      t.references :user, polymorphic: true, null: false, index: true
      t.integer :points, null: false
      t.string :transaction_type, null: false
      t.json :event_data
      t.json :offer_data
      t.datetime :expires_at
      t.text :description

      t.timestamps
    end

    add_index :referral_box_transactions, :transaction_type
    add_index :referral_box_transactions, :expires_at
    add_index :referral_box_transactions, :created_at
  end
end 