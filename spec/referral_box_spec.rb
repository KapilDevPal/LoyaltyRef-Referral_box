# frozen_string_literal: true

require "spec_helper"

RSpec.describe ReferralBox do
  it "has a version number" do
    expect(ReferralBox::VERSION).not_to be nil
  end

  it "can be configured" do
    ReferralBox.configure do |config|
      config.reference_class_name = "User"
    end
    
    expect(ReferralBox.configuration.reference_class_name).to eq("User")
  end

  describe ".earn_points" do
    it "returns false for invalid input" do
      expect(ReferralBox.earn_points(nil, 100)).to be false
      expect(ReferralBox.earn_points("user", -10)).to be false
    end
  end

  describe ".balance" do
    it "returns 0 for nil user" do
      expect(ReferralBox.balance(nil)).to eq(0)
    end
  end

  describe ".tier" do
    it "returns nil for nil user" do
      expect(ReferralBox.tier(nil)).to be nil
    end
  end
end 