# frozen_string_literal: true

module LoyaltyRef
  class TrackingController < ActionController::Base
    skip_before_action :verify_authenticity_token, only: [:track_referral]
    
    def track_referral
      ref_code = params[:ref_code]
      device_data = params[:device_data]
      
      if ref_code.present?
        success = LoyaltyRef.track_referral(
          ref_code: ref_code,
          user_agent: request.user_agent,
          ip_address: request.remote_ip,
          referrer: request.referer,
          device_data: device_data
        )
        
        if success
          render json: { success: true, message: "Referral tracked successfully" }
        else
          render json: { success: false, message: "Failed to track referral" }, status: 422
        end
      else
        render json: { success: false, message: "Referral code is required" }, status: 400
      end
    end
  end
end 