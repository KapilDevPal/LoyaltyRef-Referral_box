# frozen_string_literal: true

module ReferralBox
  class ReferralLog < ActiveRecord::Base
    self.table_name = "referral_box_referral_logs"

    belongs_to :referee, polymorphic: true, optional: true

    validates :referral_code, presence: true
    validates :clicked_at, presence: true

    scope :clicked, -> { where.not(clicked_at: nil) }
    scope :signed_up, -> { where.not(signed_up_at: nil) }
    scope :converted, -> { where.not(signed_up_at: nil).where.not(referee_id: nil) }

    def converted?
      signed_up_at.present? && referee_id.present?
    end

    def conversion_rate
      return 0 if clicked_count.zero?
      (converted_count.to_f / clicked_count * 100).round(2)
    end

    def self.clicked_count
      clicked.count
    end

    def self.converted_count
      converted.count
    end

    def self.conversion_rate
      return 0 if clicked_count.zero?
      (converted_count.to_f / clicked_count * 100).round(2)
    end

    # Device detection methods - use stored data or fallback to user_agent parsing
    def device_type
      return self[:device_type] if self[:device_type].present?
      return detect_device_type_from_user_agent if user_agent.present?
      nil
    end

    def browser
      return self[:browser] if self[:browser].present?
      return detect_browser_from_user_agent if user_agent.present?
      nil
    end

    # Geo-location methods (if using a geo service)
    def country
      return geo_data["country"] if geo_data&.dig("country").present?
      return nil unless ip_address.present?
      # You can integrate with services like MaxMind GeoIP2 or similar
      # For now, return nil - users can implement their own geo service
      nil
    end

    def city
      return geo_data["city"] if geo_data&.dig("city").present?
      return nil unless ip_address.present?
      # Implement with your preferred geo service
      nil
    end

    def latitude
      geo_data&.dig("latitude")
    end

    def longitude
      geo_data&.dig("longitude")
    end

    private

    def detect_device_type_from_user_agent
      return nil unless user_agent.present?
      
      user_agent = user_agent.downcase
      
      if user_agent.include?("mobile") || user_agent.include?("android") || user_agent.include?("iphone")
        "mobile"
      elsif user_agent.include?("tablet") || user_agent.include?("ipad")
        "tablet"
      else
        "desktop"
      end
    end

    def detect_browser_from_user_agent
      return nil unless user_agent.present?
      
      user_agent = user_agent.downcase
      
      if user_agent.include?("chrome")
        "Chrome"
      elsif user_agent.include?("firefox")
        "Firefox"
      elsif user_agent.include?("safari")
        "Safari"
      elsif user_agent.include?("edge")
        "Edge"
      else
        "Other"
      end
    end
  end
end 