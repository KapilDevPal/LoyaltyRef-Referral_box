# frozen_string_literal: true

ReferralBox::Engine.routes.draw do
  root to: "dashboard#index"
  
  get "users", to: "dashboard#users"
  get "users/:id", to: "dashboard#user", as: :user
  get "transactions", to: "dashboard#transactions"
  get "referrals", to: "dashboard#referrals"
  get "analytics", to: "dashboard#analytics"
  
  # Tracking endpoint for device data collection
  post "track_referral", to: "tracking#track_referral", as: :track_referral
end 