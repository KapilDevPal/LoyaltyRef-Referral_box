# frozen_string_literal: true

require "rails"
require "active_record"
require "action_view"
require "action_pack"

require_relative "referral_box/version"
require_relative "referral_box/engine"
require_relative "referral_box/configuration"
require_relative "referral_box/models/transaction"
require_relative "referral_box/models/referral_log"

module ReferralBox
  class << self
    def configure
      yield configuration
    end

    def configuration
      @configuration ||= Configuration.new
    end

    def earn_points(user, amount, event: nil)
      return false unless user && amount.positive?

      # Apply reward modifier based on tier
      modifier = configuration.reward_modifier&.call(user) || 1.0
      final_amount = (amount * modifier).round

      # Calculate expiration date
      expiry_days = configuration.points_expiry_days
      expires_at = expiry_days ? Time.current + expiry_days.days : nil

      # Create transaction
      transaction = Transaction.create!(
        user: user,
        points: final_amount,
        transaction_type: "earn",
        event_data: event&.as_json,
        expires_at: expires_at,
        description: "Earned #{final_amount} points"
      )

      # Update user tier if needed
      update_user_tier(user)

      transaction
    rescue => e
      Rails.logger.error "ReferralBox: Failed to earn points: #{e.message}"
      false
    end

    def redeem_points(user, points, offer: nil)
      return false unless user && points.positive?

      current_balance = balance(user)
      return false if current_balance < points

      # Calculate cost using custom rule if provided
      cost = if configuration.redeem_rule
        configuration.redeem_rule.call(user, offer)
      else
        points
      end

      # Create transaction
      transaction = Transaction.create!(
        user: user,
        points: -cost,
        transaction_type: "redeem",
        offer_data: offer&.as_json,
        description: "Redeemed #{cost} points"
      )

      transaction
    rescue => e
      Rails.logger.error "ReferralBox: Failed to redeem points: #{e.message}"
      false
    end

    def balance(user)
      return 0 unless user

      Transaction.where(user: user)
                .where("expires_at IS NULL OR expires_at > ?", Time.current)
                .sum(:points)
    end

    def tier(user)
      return nil unless user && configuration.tier_thresholds.present?

      balance = self.balance(user)
      thresholds = configuration.tier_thresholds

      # Find the highest tier the user qualifies for
      thresholds.sort_by { |_, points| points }.reverse.each do |tier_name, required_points|
        return tier_name if balance >= required_points
      end

      nil
    end

    def track_referral(ref_code:, user_agent: nil, ip_address: nil, referrer: nil, device_data: nil)
      return false unless ref_code.present?

      # Extract device and geo data from device_data parameter
      device_type = device_data&.dig("device_type")
      browser = device_data&.dig("browser")
      geo_data = device_data&.dig("geo_data")
      device_info = device_data&.except("device_type", "browser", "geo_data", "collected_at")

      ReferralLog.create!(
        referral_code: ref_code,
        user_agent: user_agent,
        ip_address: ip_address,
        referrer: referrer,
        clicked_at: Time.current,
        device_type: device_type,
        browser: browser,
        geo_data: geo_data,
        device_data: device_info
      )
    rescue => e
      Rails.logger.error "ReferralBox: Failed to track referral: #{e.message}"
      false
    end

    def process_referral_signup(referee, ref_code)
      return false unless referee && ref_code.present?

      # Find the referral log
      referral_log = ReferralLog.where(referral_code: ref_code)
                               .where(referee_id: nil)
                               .order(clicked_at: :desc)
                               .first

      return false unless referral_log

      # Find the referrer
      referrer = find_user_by_referral_code(ref_code)
      return false unless referrer

      # Update referral log
      referral_log.update!(
        referee: referee,
        signed_up_at: Time.current
      )

      # Update referee's referrer
      referee.update!(referrer: referrer)

      # Process referral rewards
      if configuration.referral_reward
        configuration.referral_reward.call(referrer, referee)
      end

      true
    rescue => e
      Rails.logger.error "ReferralBox: Failed to process referral signup: #{e.message}"
      false
    end

    private

    def update_user_tier(user)
      old_tier = user.tier
      new_tier = tier(user)

      return if old_tier == new_tier

      # Update user's tier in database
      user.update!(tier: new_tier)

      # Call tier change callback if configured
      if configuration.on_tier_changed
        configuration.on_tier_changed.call(user, old_tier, new_tier)
      end
    end

    def find_user_by_referral_code(code)
      return nil unless configuration.reference_class_name

      user_class = configuration.reference_class_name.constantize
      user_class.find_by(referral_code: code)
    rescue NameError
      Rails.logger.error "ReferralBox: User class '#{configuration.reference_class_name}' not found"
      nil
    end
  end
end 