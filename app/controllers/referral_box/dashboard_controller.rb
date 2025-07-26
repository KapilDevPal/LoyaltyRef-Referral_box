# frozen_string_literal: true

module ReferralBox
  class DashboardController < ActionController::Base
    layout "referral_box/dashboard"

    before_action :authenticate_user!
    before_action :ensure_admin_access!

    def index
      @total_users = user_class.count
      @total_transactions = ReferralBox::Transaction.count
      @total_referrals = ReferralBox::ReferralLog.count
      @conversion_rate = ReferralBox::ReferralLog.conversion_rate
      
      @recent_transactions = ReferralBox::Transaction.includes(:user)
                                                   .order(created_at: :desc)
                                                   .limit(10)
      
      @top_users = user_class.joins(:referral_box_transactions)
                            .group("users.id")
                            .order("SUM(referral_box_transactions.points) DESC")
                            .limit(10)
    end

    def users
      @users = safe_paginate(user_class.includes(:referral_box_transactions)
                        .order(created_at: :desc), 20)
    end

    def user
      @user = user_class.find(params[:id])
      @transactions = safe_paginate(@user.referral_box_transactions
                          .order(created_at: :desc), 20)
      @balance = ReferralBox.balance(@user)
      @tier = ReferralBox.tier(@user)
    end

    def transactions
      @transactions = safe_paginate(ReferralBox::Transaction.includes(:user)
                                            .order(created_at: :desc), 50)
    end

    def referrals
      @referrals = safe_paginate(ReferralBox::ReferralLog.order(clicked_at: :desc), 50)
    end

    def analytics
      @total_clicks = ReferralBox::ReferralLog.clicked_count
      @total_conversions = ReferralBox::ReferralLog.converted_count
      @conversion_rate = ReferralBox::ReferralLog.conversion_rate
      
      @referrals_by_device = ReferralBox::ReferralLog.group(:device_type).count
      @referrals_by_browser = ReferralBox::ReferralLog.group(:browser).count
      
      @daily_clicks = ReferralBox::ReferralLog.group("DATE(clicked_at)")
                                            .count
                                            .sort_by { |date, _| date }
                                            .last(30)
    end

    private

    def user_class
      ReferralBox.configuration.reference_class_name.constantize
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