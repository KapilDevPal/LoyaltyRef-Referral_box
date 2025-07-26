# LoyaltyRef Gem - Complete Developer Guide

## 📖 Table of Contents

1. [Quick Start](#quick-start)
2. [Installation](#installation)
3. [Configuration](#configuration)
4. [Flexible Model Support](#flexible-model-support)
5. [Core Features](#core-features)
6. [API Reference](#api-reference)
7. [Admin Dashboard](#admin-dashboard)
8. [Advanced Usage](#advanced-usage)
9. [Troubleshooting](#troubleshooting)
10. [Examples](#examples)

---

## 🚀 Quick Start

Add to your Gemfile and get started in minutes:

```ruby
# Gemfile
gem 'loyalty_ref'
```

```bash
bundle install
rails generate loyalty_ref:install
rails db:migrate
```

Visit `/loyalty` to see your admin dashboard!

---

## 📦 Installation

### Step 1: Add to Gemfile

```ruby
# Gemfile
gem 'loyalty_ref'
```

### Step 2: Install Dependencies

```bash
bundle install
```

### Step 3: Run Generator

```bash
rails generate loyalty_ref:install
```

This will:
- Create `config/initializers/loyalty_ref.rb`
- Ask if you want to add columns to your model
- Set up basic configuration

### Step 4: Run Migrations

```bash
rails db:migrate
```

This creates:
- `loyalty_ref_transactions` table
- `loyalty_ref_referral_logs` table
- Adds `referral_code` and `tier` columns to your model table

### Step 5: Update Your Model

Add to your model file (e.g., `app/models/user.rb`, `app/models/customer.rb`, etc.):

```ruby
class User < ApplicationRecord  # or Customer, Account, etc.
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
      self.referral_code = SecureRandom.alphanumeric(LoyaltyRef.configuration.referral_code_length).upcase
      break unless User.exists?(referral_code: referral_code)
    end
  end
end
```

---

## 🔄 Flexible Model Support

**LoyaltyRef works with ANY model!** You're not limited to just `User`. Here are examples:

### Example 1: Customer Model

```ruby
# config/initializers/loyalty_ref.rb
LoyaltyRef.configure do |config|
  config.reference_class_name = 'Customer'
  # ... other config
end

# app/models/customer.rb
class Customer < ApplicationRecord
  has_many :loyalty_ref_transactions, class_name: 'LoyaltyRef::Transaction', as: :user
  has_many :referrals, class_name: 'Customer', foreign_key: 'referrer_id'
  belongs_to :referrer, class_name: 'Customer', optional: true

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
      self.referral_code = SecureRandom.alphanumeric(LoyaltyRef.configuration.referral_code_length).upcase
      break unless Customer.exists?(referral_code: referral_code)
    end
  end
end
```

### Example 2: Account Model

```ruby
# config/initializers/loyalty_ref.rb
LoyaltyRef.configure do |config|
  config.reference_class_name = 'Account'
  # ... other config
end

# app/models/account.rb
class Account < ApplicationRecord
  has_many :loyalty_ref_transactions, class_name: 'LoyaltyRef::Transaction', as: :user
  has_many :referrals, class_name: 'Account', foreign_key: 'referrer_id'
  belongs_to :referrer, class_name: 'Account', optional: true

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
      self.referral_code = SecureRandom.alphanumeric(LoyaltyRef.configuration.referral_code_length).upcase
      break unless Account.exists?(referral_code: referral_code)
    end
  end
end
```

### Example 3: Member Model

```ruby
# config/initializers/loyalty_ref.rb
LoyaltyRef.configure do |config|
  config.reference_class_name = 'Member'
  # ... other config
end

# app/models/member.rb
class Member < ApplicationRecord
  has_many :loyalty_ref_transactions, class_name: 'LoyaltyRef::Transaction', as: :user
  has_many :referrals, class_name: 'Member', foreign_key: 'referrer_id'
  belongs_to :referrer, class_name: 'Member', optional: true

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
      self.referral_code = SecureRandom.alphanumeric(LoyaltyRef.configuration.referral_code_length).upcase
      break unless Member.exists?(referral_code: referral_code)
    end
  end
end
```

### Migration Examples

#### For Customer Model:
```bash
rails generate migration AddLoyaltyRefToCustomers referral_code:string tier:string referrer:references
```

#### For Account Model:
```bash
rails generate migration AddLoyaltyRefToAccounts referral_code:string tier:string referrer:references
```

#### For Member Model:
```bash
rails generate migration AddLoyaltyRefToMembers referral_code:string tier:string referrer:references
```

### Key Points:

1. **Change `reference_class_name`** in your initializer
2. **Update model associations** to use your model name
3. **Update `generate_referral_code`** method to use your model
4. **Run appropriate migrations** for your model table

### Usage with Different Models:

```ruby
# With Customer model
customer = Customer.create!(email: "john@example.com")
LoyaltyRef.earn_points(customer, 100)
balance = LoyaltyRef.balance(customer)

# With Account model
account = Account.create!(name: "Business Account")
LoyaltyRef.earn_points(account, 100)
tier = LoyaltyRef.tier(account)

# With Member model
member = Member.create!(username: "john_doe")
LoyaltyRef.earn_points(member, 100)
referral_link = member.referral_link
```

---

## ⚙️ Configuration

### Basic Configuration

```ruby
# config/initializers/loyalty_ref.rb

LoyaltyRef.configure do |config|
  # Define your model (User, Customer, Account, Member, etc.)
  config.reference_class_name = 'User'  # or 'Customer', 'Account', etc.

  # Points earning rule
  config.earning_rule = ->(user, event) do
    # Example: earn 10 points per ₹100 spent
    event.amount / 10
  end

  # Tier thresholds
  config.tier_thresholds = {
    "Silver" => 500,
    "Gold" => 1000,
    "Platinum" => 2500
  }

  # Reward multiplier by tier
  config.reward_modifier = ->(user) do
    case user.tier
    when "Silver" then 1.0
    when "Gold" then 1.2
    when "Platinum" then 1.5
    else 1.0
    end
  end

  # Referral rewards
  config.referral_reward = ->(referrer, referee) do
    LoyaltyRef.earn_points(referrer, 100)
    LoyaltyRef.earn_points(referee, 50)
  end

  # Points expiration (days)
  config.points_expiry_days = 90

  # Referral code length
  config.referral_code_length = 8

  # Admin dashboard path
  config.admin_route_path = "/loyalty"
end
```

### Configuration Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `reference_class_name` | String | 'User' | Your model class name (User, Customer, Account, etc.) |
| `earning_rule` | Lambda | `->(user, event) { 1 }` | Custom points earning logic |
| `redeem_rule` | Lambda | `->(user, offer) { 100 }` | Custom points redemption logic |
| `tier_thresholds` | Hash | `{"Silver"=>500, "Gold"=>1000, "Platinum"=>2500}` | Points needed for each tier |
| `reward_modifier` | Lambda | `->(user) { 1.0 }` | Points multiplier by tier |
| `referral_reward` | Lambda | `nil` | Logic for referral rewards |
| `points_expiry_days` | Integer | 90 | Days until points expire |
| `referral_code_length` | Integer | 8 | Length of referral codes |
| `admin_route_path` | String | '/loyalty' | Admin dashboard URL path |
| `on_tier_changed` | Lambda | `nil` | Callback when user tier changes |

---

## 🎁 Core Features

### 1. Points System

#### Earn Points

```ruby
# Basic earning
LoyaltyRef.earn_points(user, 100)

# With event data
LoyaltyRef.earn_points(user, 100, event: order)

# Custom earning rule (defined in config)
LoyaltyRef.earn_points(user, order.amount, event: order)
```

#### Redeem Points

```ruby
# Redeem points
LoyaltyRef.redeem_points(user, 50)

# With offer data
LoyaltyRef.redeem_points(user, 50, offer: coupon)
```

#### Check Balance

```ruby
# Get current balance
balance = LoyaltyRef.balance(user)

# Check if user has enough points
if LoyaltyRef.balance(user) >= 100
  # Process redemption
end
```

### 2. Tier System

#### Automatic Tier Assignment

```ruby
# Get current tier
tier = LoyaltyRef.tier(user)
# Returns: "Silver", "Gold", "Platinum", or nil

# Check if user is in specific tier
if LoyaltyRef.tier(user) == "Gold"
  # Apply Gold tier benefits
end
```

#### Tier Change Callback

```ruby
# In your initializer
config.on_tier_changed = ->(user, old_tier, new_tier) do
  UserMailer.tier_changed(user, old_tier, new_tier).deliver_later
end
```

### 3. Referral System

#### Track Referral Clicks

```ruby
# Track when someone clicks a referral link
LoyaltyRef.track_referral(
  ref_code: params[:ref],
  user_agent: request.user_agent,
  ip_address: request.remote_ip
)
```

#### Process Referral Signups

```ruby
# When new user signs up with referral code
LoyaltyRef.process_referral_signup(new_user, ref_code)
```

#### Get Referral Analytics

```ruby
# Get referral statistics
total_clicks = LoyaltyRef::ReferralLog.clicked_count
total_conversions = LoyaltyRef::ReferralLog.converted_count
conversion_rate = LoyaltyRef::ReferralLog.conversion_rate
```

---

## 📚 API Reference

### Core Methods

#### `LoyaltyRef.earn_points(user, amount, event: nil)`

Earns points for a user.

**Parameters:**
- `user` - User object (or Customer, Account, etc.)
- `amount` - Points to earn (integer)
- `event` - Optional event object for custom earning rules

**Returns:** Transaction object or false

**Example:**
```ruby
transaction = LoyaltyRef.earn_points(user, 100, event: order)
```

#### `LoyaltyRef.redeem_points(user, points, offer: nil)`

Redeems points from a user's balance.

**Parameters:**
- `user` - User object (or Customer, Account, etc.)
- `points` - Points to redeem (integer)
- `offer` - Optional offer object

**Returns:** Transaction object or false

**Example:**
```ruby
transaction = LoyaltyRef.redeem_points(user, 50, offer: coupon)
```

#### `LoyaltyRef.balance(user)`

Gets the current points balance for a user.

**Parameters:**
- `user` - User object (or Customer, Account, etc.)

**Returns:** Integer (points balance)

**Example:**
```ruby
balance = LoyaltyRef.balance(user)
```

#### `LoyaltyRef.tier(user)`

Gets the current tier for a user.

**Parameters:**
- `user` - User object (or Customer, Account, etc.)

**Returns:** String (tier name) or nil

**Example:**
```ruby
tier = LoyaltyRef.tier(user)
```

#### `LoyaltyRef.track_referral(ref_code:, user_agent: nil, ip_address: nil, referrer: nil)`

Tracks a referral link click.

**Parameters:**
- `ref_code` - Referral code (required)
- `user_agent` - Browser user agent
- `ip_address` - IP address
- `referrer` - Referrer URL

**Returns:** ReferralLog object or false

**Example:**
```ruby
log = LoyaltyRef.track_referral(
  ref_code: params[:ref],
  user_agent: request.user_agent,
  ip_address: request.remote_ip
)
```

#### `LoyaltyRef.process_referral_signup(referee, ref_code)`

Processes a referral signup.

**Parameters:**
- `referee` - New user who signed up (or Customer, Account, etc.)
- `ref_code` - Referral code used

**Returns:** Boolean (success/failure)

**Example:**
```ruby
success = LoyaltyRef.process_referral_signup(new_user, ref_code)
```

### Model Methods

#### Model Methods (for any model: User, Customer, Account, etc.)

```ruby
user.points_balance          # Get points balance
user.current_tier           # Get current tier
user.referral_link          # Get referral link URL
user.total_referrals        # Count total referrals
user.successful_referrals   # Count successful referrals
```

---

## 🖥️ Admin Dashboard

### Access Dashboard

Visit: `http://your-app.com/loyalty`

### Dashboard Features

1. **Overview Dashboard**
   - Total users, transactions, referrals
   - Conversion rate
   - Recent transactions
   - Top users by points

2. **Users Management**
   - List all users with points and tiers
   - View user details
   - See referral codes

3. **Transactions**
   - Complete transaction history
   - Filter by type (earn/redeem)
   - Search and pagination

4. **Referrals**
   - Referral click tracking
   - Conversion analytics
   - Device and browser stats

5. **Analytics**
   - Referral performance
   - Device breakdown
   - Daily click trends

### Customize Dashboard Path

```ruby
# In your initializer
config.admin_route_path = "/admin/loyalty"
```

---

## 🔧 Advanced Usage

### Custom Earning Rules

```ruby
# Points based on order amount
config.earning_rule = ->(user, event) do
  case event.class.name
  when 'Order'
    event.amount / 10  # 10 points per $1
  when 'Review'
    50  # 50 points for reviews
  else
    1   # Default 1 point
  end
end
```

### Custom Tier Logic

```ruby
# Dynamic tier calculation
config.tier_thresholds = ->(user) do
  if user.vip?
    { "VIP" => 100, "VIP Gold" => 500, "VIP Platinum" => 1000 }
  else
    { "Bronze" => 100, "Silver" => 500, "Gold" => 1000 }
  end
end
```

### Referral Rewards

```ruby
# Complex referral rewards
config.referral_reward = ->(referrer, referee) do
  # Give referrer points
  LoyaltyRef.earn_points(referrer, 100)
  
  # Give referee welcome bonus
  LoyaltyRef.earn_points(referee, 50)
  
  # Send notifications
  ReferralMailer.welcome_bonus(referee).deliver_later
  ReferralMailer.referral_bonus(referrer).deliver_later
end
```

### Points Expiration

```ruby
# Custom expiration logic
config.points_expiry_days = ->(user, points) do
  if user.vip?
    365  # VIP users get 1 year
  else
    90   # Regular users get 90 days
  end
end
```

---

## 🛠️ Integration Examples

### E-commerce Integration

```ruby
# In your Order model
class Order < ApplicationRecord
  belongs_to :user  # or customer, account, etc.
  
  after_create :award_points
  
  private
  
  def award_points
    LoyaltyRef.earn_points(user, order_total, event: self)
  end
end

# In your Coupon model
class Coupon < ApplicationRecord
  def apply_to_order(order)
    points_cost = cost_in_points
    if LoyaltyRef.balance(order.user) >= points_cost
      LoyaltyRef.redeem_points(order.user, points_cost, offer: self)
      order.apply_discount(discount_amount)
    end
  end
end
```

### Referral Integration

```ruby
# In your ApplicationController
class ApplicationController < ActionController::Base
  before_action :track_referral
  
  private
  
  def track_referral
    if params[:ref].present?
      LoyaltyRef.track_referral(
        ref_code: params[:ref],
        user_agent: request.user_agent,
        ip_address: request.remote_ip
      )
    end
  end
end

# In your UsersController (or CustomersController, etc.)
class UsersController < ApplicationController
  def create
    @user = User.new(user_params)
    
    if @user.save
      # Process referral if present
      if session[:referral_code].present?
        LoyaltyRef.process_referral_signup(@user, session[:referral_code])
      end
      
      redirect_to @user
    else
      render :new
    end
  end
end
```

### API Integration

```ruby
# API endpoint for points balance
class Api::LoyaltyController < ApplicationController
  def balance
    render json: {
      balance: LoyaltyRef.balance(current_user),
      tier: LoyaltyRef.tier(current_user),
      referral_code: current_user.referral_code
    }
  end
  
  def earn_points
    amount = params[:amount].to_i
    transaction = LoyaltyRef.earn_points(current_user, amount)
    
    if transaction
      render json: { success: true, new_balance: LoyaltyRef.balance(current_user) }
    else
      render json: { success: false, error: "Failed to earn points" }
    end
  end
end
```

---

## 🔍 Troubleshooting

### Common Issues

#### 1. "undefined method 'page'" Error

**Problem:** Kaminari pagination not working

**Solution:** The gem includes Kaminari automatically. If you still get errors, restart your Rails server:

```bash
rails server
```

#### 2. "uninitialized constant LoyaltyRef" Error

**Problem:** Gem not loaded properly

**Solution:**
```bash
bundle install
rails server
```

#### 3. Migration Errors

**Problem:** Database migration fails

**Solution:**
```bash
rails db:rollback
rails db:migrate
```

#### 4. Admin Dashboard Not Loading

**Problem:** Dashboard routes not working

**Solution:** Check your routes.rb file. The gem should auto-mount at `/loyalty`.

#### 5. Referral Codes Not Generating

**Problem:** Referral codes not created automatically

**Solution:** Make sure your model has the `before_create :generate_referral_code` callback.

### Debug Mode

Enable debug logging:

```ruby
# In your initializer
LoyaltyRef.configure do |config|
  config.debug = true
end
```

### Check Configuration

```ruby
# In Rails console
puts LoyaltyRef.configuration.reference_class_name
puts LoyaltyRef.configuration.tier_thresholds
```

---

## 📝 Examples

### Complete E-commerce Example

```ruby
# config/initializers/loyalty_ref.rb
LoyaltyRef.configure do |config|
  config.reference_class_name = 'Customer'  # Using Customer model
  
  config.earning_rule = ->(customer, event) do
    case event.class.name
    when 'Order'
      event.amount / 10  # 10 points per $1
    when 'Review'
      50  # 50 points for reviews
    when 'Referral'
      100 # 100 points for referrals
    else
      1
    end
  end
  
  config.tier_thresholds = {
    "Bronze" => 100,
    "Silver" => 500,
    "Gold" => 1000,
    "Platinum" => 2500
  }
  
  config.reward_modifier = ->(customer) do
    case customer.tier
    when "Bronze" then 1.0
    when "Silver" then 1.1
    when "Gold" then 1.2
    when "Platinum" then 1.5
    else 1.0
    end
  end
  
  config.referral_reward = ->(referrer, referee) do
    LoyaltyRef.earn_points(referrer, 100, event: OpenStruct.new(class: { name: 'Referral' }))
    LoyaltyRef.earn_points(referee, 50, event: OpenStruct.new(class: { name: 'Referral' }))
  end
  
  config.points_expiry_days = 90
  config.referral_code_length = 8
end
```

### Customer Model Example

```ruby
class Customer < ApplicationRecord
  has_many :loyalty_ref_transactions, class_name: 'LoyaltyRef::Transaction', as: :user
  has_many :referrals, class_name: 'Customer', foreign_key: 'referrer_id'
  belongs_to :referrer, class_name: 'Customer', optional: true
  
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
  
  def can_redeem?(points)
    LoyaltyRef.balance(self) >= points
  end
  
  def tier_benefits
    case current_tier
    when "Gold"
      { discount: 0.1, free_shipping: true }
    when "Platinum"
      { discount: 0.15, free_shipping: true, priority_support: true }
    else
      { discount: 0.05, free_shipping: false }
    end
  end
  
  private
  
  def generate_referral_code
    return if referral_code.present?
    
    loop do
      self.referral_code = SecureRandom.alphanumeric(LoyaltyRef.configuration.referral_code_length).upcase
      break unless Customer.exists?(referral_code: referral_code)
    end
  end
end
```

---

## 🆘 Support

### Getting Help

1. **Check the documentation** - This guide covers most use cases
2. **Review the examples** - See working implementations
3. **Check the admin dashboard** - `/loyalty` for debugging
4. **Use Rails console** - Test methods directly

### Useful Console Commands

```ruby
# Test basic functionality
customer = Customer.first  # or User.first, Account.first, etc.
LoyaltyRef.earn_points(customer, 100)
puts LoyaltyRef.balance(customer)
puts LoyaltyRef.tier(customer)

# Check configuration
puts LoyaltyRef.configuration.reference_class_name
puts LoyaltyRef.configuration.tier_thresholds

# Test referral tracking
LoyaltyRef.track_referral(ref_code: customer.referral_code)

# Check transaction history
LoyaltyRef::Transaction.where(user: customer).count
```

### Version Information

```ruby
puts LoyaltyRef::VERSION
```

---

## 📄 License

MIT License - See LICENSE.txt for details.

---

**Happy coding with LoyaltyRef! 🎉** 