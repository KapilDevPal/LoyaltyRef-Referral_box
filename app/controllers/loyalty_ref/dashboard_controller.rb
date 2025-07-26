# frozen_string_literal: true

module LoyaltyRef
  class DashboardController < ActionController::Base
    layout "loyalty_ref/dashboard"

    before_action :authenticate_user!
    before_action :ensure_admin_access!

    def index
      @total_users = user_class.count
      @total_transactions = LoyaltyRef::Transaction.count
      @total_referrals = LoyaltyRef::ReferralLog.count
      @conversion_rate = LoyaltyRef::ReferralLog.conversion_rate
      
      @recent_transactions = LoyaltyRef::Transaction.includes(:user)
                                                   .order(created_at: :desc)
                                                   .limit(10)
      
      @top_users = user_class.joins(:loyalty_ref_transactions)
                            .group("users.id")
                            .order("SUM(loyalty_ref_transactions.points) DESC")
                            .limit(10)
    end

    def users
      @users = safe_paginate(user_class.includes(:loyalty_ref_transactions)
                        .order(created_at: :desc), 20)
    end

    def user
      @user = user_class.find(params[:id])
      @transactions = safe_paginate(@user.loyalty_ref_transactions
                          .order(created_at: :desc), 20)
      @balance = LoyaltyRef.balance(@user)
      @tier = LoyaltyRef.tier(@user)
    end

    def transactions
      @transactions = safe_paginate(LoyaltyRef::Transaction.includes(:user)
                                            .order(created_at: :desc), 50)
    end

    def referrals
      @referrals = safe_paginate(LoyaltyRef::ReferralLog.order(clicked_at: :desc), 50)
    end

    def analytics
      @total_clicks = LoyaltyRef::ReferralLog.clicked_count
      @total_conversions = LoyaltyRef::ReferralLog.converted_count
      @conversion_rate = LoyaltyRef::ReferralLog.conversion_rate
      
      @referrals_by_device = LoyaltyRef::ReferralLog.group(:device_type).count
      @referrals_by_browser = LoyaltyRef::ReferralLog.group(:browser).count
      
      @daily_clicks = LoyaltyRef::ReferralLog.group("DATE(clicked_at)")
                                            .count
                                            .sort_by { |date, _| date }
                                            .last(30)
    end

    private

    def user_class
      LoyaltyRef.configuration.reference_class_name.constantize
    end

    def safe_paginate(relation, per_page = 20)
      if defined?(Kaminari) && relation.respond_to?(:page)
        relation.page(params[:page]).per(per_page)
      else
        # Fallback pagination without Kaminari
        page = (params[:page] || 1).to_i
        offset = (page - 1) * per_page
        relation.offset(offset).limit(per_page)
      end
    end

    def authenticate_user!
      # Override this method in your app to implement authentication
      # For example: redirect_to login_path unless current_user
      true
    end

    def ensure_admin_access!
      # Override this method in your app to implement admin authorization
      # For example: redirect_to root_path unless current_user&.admin?
      true
    end
  end
end 