 # frozen_string_literal: true

class User < ApplicationRecord
  # Add these columns to your users table:
  # add_column :users, :referral_code, :string
  # add_column :users, :tier, :string
  # add_index :users, :referral_code, unique: true

  has_many :loyalty_ref_transactions, class_name: 'LoyaltyRef::Transaction', as: :user
  has_many :referrals, class_name: 'User', foreign_key: 'referrer_id'
  belongs_to :referrer, class_name: 'User', optional: true

  before_create :generate_referral_code

  def points_balance
    LoyaltyRef.balance(self)
  end

  def current_tier
    LoyaltyRef.tier(self)
  end

  def referral_link
    "#{Rails.application.routes.url_helpers.root_url}?ref=#{referral_code}"
  end

  def total_referrals
    referrals.count
  end

  def successful_referrals
    referrals.joins(:loyalty_ref_transactions).distinct.count
  end

  private

  def generate_referral_code
    return if referral_code.present?

    loop do
      self.referral_code = SecureRandom.alphanumeric(LoyaltyRef.configuration.referral_code_length).upcase
      break unless User.exists?(referral_code: referral_code)
    end
  end
end 