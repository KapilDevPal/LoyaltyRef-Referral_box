# frozen_string_literal: true

require "spec_helper"

RSpec.describe LoyaltyRef do
  it "has a version number" do
    expect(LoyaltyRef::VERSION).not_to be nil
  end

  describe ".configure" do
    it "allows configuration" do
      LoyaltyRef.configure do |config|
        config.reference_class_name = "TestUser"
        config.points_expiry_days = 30
      end

      expect(LoyaltyRef.configuration.reference_class_name).to eq("TestUser")
      expect(LoyaltyRef.configuration.points_expiry_days).to eq(30)
    end
  end

  describe ".balance" do
    it "returns 0 for nil user" do
      expect(LoyaltyRef.balance(nil)).to eq(0)
    end
  end

  describe ".tier" do
    it "returns nil for nil user" do
      expect(LoyaltyRef.tier(nil)).to be_nil
    end
  end
end 