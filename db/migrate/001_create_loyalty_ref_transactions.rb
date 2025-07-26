# frozen_string_literal: true

class CreateLoyaltyRefTransactions < ActiveRecord::Migration[7.0]
  def change
    create_table :loyalty_ref_transactions do |t|
      t.references :user, polymorphic: true, null: false, index: true
      t.integer :points, null: false
      t.string :transaction_type, null: false
      t.json :event_data
      t.json :offer_data
      t.datetime :expires_at
      t.text :description

      t.timestamps
    end

    add_index :loyalty_ref_transactions, :transaction_type
    add_index :loyalty_ref_transactions, :expires_at
    add_index :loyalty_ref_transactions, :created_at
  end
end 