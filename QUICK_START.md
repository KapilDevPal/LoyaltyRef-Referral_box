# LoyaltyRef - Quick Start Guide

Get your loyalty and referral system running in 5 minutes! 🚀

## ⚡ Super Quick Setup

### 1. Add to Gemfile
```ruby
gem 'loyalty_ref'
```

### 2. Install & Setup
```bash
bundle install
rails generate loyalty_ref:install
rails db:migrate
```

### 3. Update Your Model
Add this to your model file (e.g., `app/models/user.rb`, `app/models/customer.rb`, etc.):

```ruby
class User < ApplicationRecord  # or Customer, Account, Member, etc.
  has_many :loyalty_ref_transactions, class_name: 'LoyaltyRef::Transaction', as: :user
  has_many :referrals, class_name: 'User', foreign_key: 'referrer_id'
  belongs_to :referrer, class_name: 'User', optional: true

  before_create :generate_referral_code

  def points_balance
    LoyaltyRef.balance(self)
  end

  def current_tier
    LoyaltyRef.tier(self)
  end

  def referral_link
    "#{Rails.application.routes.url_helpers.root_url}?ref=#{referral_code}"
  end

  private

  def generate_referral_code
    return if referral_code.present?
    loop do
      self.referral_code = SecureRandom.alphanumeric(8).upcase
      break unless User.exists?(referral_code: referral_code)
    end
  end
end
```

### 4. Test It!
```bash
rails server
```

Visit: `http://localhost:3000/loyalty` - Your admin dashboard!

## 🔄 Flexible Model Support

**LoyaltyRef works with ANY model!** You can use:
- `User` (default)
- `Customer`
- `Account`
- `Member`
- Any other model you have

Just change the `reference_class_name` in your initializer:

```ruby
# config/initializers/loyalty_ref.rb
LoyaltyRef.configure do |config|
  config.reference_class_name = 'Customer'  # or 'Account', 'Member', etc.
  # ... rest of config
end
```

## 🎯 Basic Usage

### Earn Points
```ruby
# In your controller
LoyaltyRef.earn_points(current_user, 100)  # or current_customer, etc.
```

### Check Balance
```ruby
balance = LoyaltyRef.balance(current_user)
tier = LoyaltyRef.tier(current_user)
```

### Track Referrals
```ruby
# When someone clicks a referral link
LoyaltyRef.track_referral(ref_code: params[:ref])

# When someone signs up with referral
LoyaltyRef.process_referral_signup(new_user, ref_code)
```

## ⚙️ Basic Configuration

Edit `config/initializers/loyalty_ref.rb`:

```ruby
LoyaltyRef.configure do |config|
  config.reference_class_name = 'User'  # or 'Customer', 'Account', etc.
  
  # Earn 10 points per $1 spent
  config.earning_rule = ->(user, event) do
    event.amount / 10
  end
  
  # Tier thresholds
  config.tier_thresholds = {
    "Silver" => 500,
    "Gold" => 1000,
    "Platinum" => 2500
  }
  
  # Referral rewards
  config.referral_reward = ->(referrer, referee) do
    LoyaltyRef.earn_points(referrer, 100)
    LoyaltyRef.earn_points(referee, 50)
  end
end
```

## 🎉 That's It!

Your loyalty system is now running with:
- ✅ Points earning and redemption
- ✅ Automatic tier assignment
- ✅ Referral tracking
- ✅ Beautiful admin dashboard
- ✅ Analytics and reporting
- ✅ Works with any model (User, Customer, Account, etc.)

## 📚 Next Steps

- **Full Documentation**: See `DOCUMENTATION.md` for advanced features
- **Customization**: Configure earning rules, tiers, and rewards
- **Integration**: Add to your e-commerce, user registration, etc.
- **Model Flexibility**: Use with Customer, Account, Member, or any model

## 🆘 Need Help?

- **Admin Dashboard**: `/loyalty` - See all your data
- **Rails Console**: Test methods directly
- **Full Guide**: `DOCUMENTATION.md` - Complete reference

---

**Happy coding! 🎉** 