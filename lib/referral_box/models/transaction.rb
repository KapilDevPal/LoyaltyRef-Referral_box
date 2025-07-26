# frozen_string_literal: true

module ReferralBox
  class Transaction < ActiveRecord::Base
    self.table_name = "referral_box_transactions"

    belongs_to :user, polymorphic: true

    validates :user, presence: true
    validates :points, presence: true, numericality: { only_integer: true }
    validates :transaction_type, presence: true, inclusion: { in: %w[earn redeem adjust] }

    scope :earned, -> { where(transaction_type: "earn") }
    scope :redeemed, -> { where(transaction_type: "redeem") }
    scope :adjusted, -> { where(transaction_type: "adjust") }
    scope :active, -> { where("expires_at IS NULL OR expires_at > ?", Time.current) }
    scope :expired, -> { where("expires_at IS NOT NULL AND expires_at <= ?", Time.current) }

    def expired?
      expires_at.present? && expires_at <= Time.current
    end

    def active?
      !expired?
    end

    def earned?
      transaction_type == "earn"
    end

    def redeemed?
      transaction_type == "redeem"
    end

    def adjusted?
      transaction_type == "adjust"
    end
  end
end 