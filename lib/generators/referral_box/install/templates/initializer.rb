# frozen_string_literal: true

ReferralBox.configure do |config|
  # Define which model represents your app's user/customer
  config.reference_class_name = 'User' # or 'Customer', 'Account', etc.

  # Custom earning rule - earn points based on events
  config.earning_rule = ->(user, event) do
    # Example: earn 10 points per ₹100 spent
    # event.amount / 10
    
    # Default: earn 1 point per event
    1
  end

  # Custom redeem rule - how many points to deduct
  config.redeem_rule = ->(user, offer) do
    # Example: offer.cost_in_points
    offer&.cost_in_points || 100
  end

  # Define tier thresholds
  config.tier_thresholds = {
    "Silver" => 500,
    "Gold" => 1000,
    "Platinum" => 2500
  }

  # Reward modifier based on tier
  config.reward_modifier = ->(user) do
    case user.tier
    when "Silver" then 1.0
    when "Gold" then 1.2
    when "Platinum" then 1.5
    else 1.0
    end
  end

  # Referral reward logic
  config.referral_reward = ->(referrer, referee) do
    ReferralBox.earn_points(referrer, 100)
    ReferralBox.earn_points(referee, 50)
  end

  # Points expiration (in days)
  config.points_expiry_days = 90

  # Referral code length
  config.referral_code_length = 8

  # Admin dashboard route path
  config.admin_route_path = "/referral_box"

  # Device tracking and analytics
  config.enable_device_tracking = true  # Enable device detection
  config.collect_geo_location = false   # Enable geo-location (requires user consent)

  # Optional: Callback when user's tier changes
  config.on_tier_changed = ->(user, old_tier, new_tier) do
    # Example: Send notification email
    # UserMailer.tier_changed(user, old_tier, new_tier).deliver_later
  end
end 