# frozen_string_literal: true

module LoyaltyRef
  class Configuration
    attr_accessor :reference_class_name,
                  :earning_rule,
                  :redeem_rule,
                  :tier_thresholds,
                  :reward_modifier,
                  :referral_reward,
                  :on_tier_changed,
                  :points_expiry_days,
                  :referral_code_length,
                  :admin_route_path,
                  :enable_device_tracking,
                  :collect_geo_location

    def initialize
      @reference_class_name = "User"
      @tier_thresholds = {
        "Silver" => 500,
        "Gold" => 1000,
        "Platinum" => 2500
      }
      @points_expiry_days = 90
      @referral_code_length = 8
      @admin_route_path = "/loyalty"
      @enable_device_tracking = true
      @collect_geo_location = false  # Default to false for privacy
    end
  end
end 