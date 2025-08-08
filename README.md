# ReferralBox 📦
**PLEASE VISIT THIS**
GEM BEEN Updated 
https://github.com/KapilDevPal/Referral_box


A flexible Ruby gem for building loyalty and referral systems in Rails apps.

* 🎁 Reward users with points based on their activity
* 🧱 Create dynamic tier levels (Silver, Gold, Platinum)
* 🤝 Add referral rewards with unique referral codes
* 🔧 Fully customizable and configurable
* 🎛️ Admin dashboard (ERB based)
* 🔄 Supports any user model: `User`, `Customer`, `Account`, etc.

---

## 📚 Documentation

- **[Quick Start Guide](QUICK_START.md)** - Get running in 5 minutes
- **[Complete Documentation](DOCUMENTATION.md)** - Full developer guide with examples
- **[API Reference](DOCUMENTATION.md#api-reference)** - All methods and options

---

## 🚀 Installation

```ruby
# Gemfile
gem 'referral_box'
```

```bash
$ bundle install
$ rails generate referral_box:install
$ rails db:migrate
```

---

## 🛠️ Configuration

Create your configuration block in an initializer:

```ruby
# config/initializers/referral_box.rb

ReferralBox.configure do |config|
  # Define which model represents your app's user/customer
  config.reference_class_name = 'User' # or 'Customer', 'Account', etc.

  config.earning_rule = ->(user, event) do
    # Example: earn 10 points per ₹100 spent
    event.amount / 10
  end

  config.redeem_rule = ->(user, offer) do
    offer.cost_in_points
  end

  config.tier_thresholds = {
    "Silver" => 500,
    "Gold" => 1000,
    "Platinum" => 2500
  }

  config.reward_modifier = ->(user) do
    case user.tier
    when "Silver" then 1.0
    when "Gold" then 1.2
    when "Platinum" then 1.5
    else 1.0
    end
  end

  config.referral_reward = ->(referrer, referee) do
    ReferralBox.earn_points(referrer, 100)
    ReferralBox.earn_points(referee, 50)
  end
end
```

---

## ✅ Features

### 🎁 Loyalty Program

| Feature              | Description                   |
| -------------------- | ----------------------------- |
| Points system        | Earn points via config lambda |
| Custom earning rules | Define rules per event/user   |
| Redeem points        | Redeem points for offers      |
| Manual adjustment    | Admins can modify balances    |
| Points expiration    | e.g. 90 days                  |
| Transaction logging  | All activity is logged        |
| Check balance        | Easy method to check          |

### 🧱 Tier System (Dynamic)

| Feature                 | Description                 |
| ----------------------- | --------------------------- |
| Dynamic definitions     | e.g. Silver => 500 points   |
| Auto tier assignment    | Based on balance            |
| Callbacks on promotion  | `on_tier_changed` hook      |
| Reward modifier by tier | e.g. Gold users get +20%    |
| DB persistence          | Can store or calculate tier |

### 🤝 Referral System

| Feature               | Description                                                   |
| --------------------- | ------------------------------------------------------------- |
| Unique referral codes | Auto-generated or custom                                      |
| ?ref=code tracking    | Via signup links                                              |
| Multi-level referrals | Parent/child tree                                             |
| Referral rewards      | Custom logic supported                                        |
| Referral analytics    | Track clicks, accepted signups, geo-location, and device type |

### ⚙️ Core Gem Features

* Developer config block
* Extensible models
* Simple public API: `earn_points`, `redeem_points`, `balance`, `track_referral`
* Rails generators for setup
* Support for any user model (User, Account, Customer, etc.)

### 🖥️ Admin UI

* Mountable engine with ERB templates
* Routes like `/referral_box`
* Views to list users, transactions, referrals

---

## 🔮 Future Scope

### 📊 Analytics & Admin

* Leaderboards by points
* Referral tree visualizer
* ActiveAdmin / custom dashboard
* Export CSV/JSON of logs

### 🔔 Engagement

* Email / in-app notifications
* Badges based on milestones
* Activity calendar
* Social sharing for referral links

---

## 📂 Folder Structure (Gem)

```
lib/
├── referral_box.rb
├── referral_box/
│   ├── engine.rb
│   ├── configuration.rb
│   ├── version.rb
│   ├── models/
│   │   ├── transaction.rb
│   │   ├── referral_log.rb
│   └── controllers/
│       ├── dashboard_controller.rb
app/views/referral_box/dashboard/
  ├── index.html.erb
  ├── show.html.erb
```

---

## 🧪 Usage Examples

```ruby
# Earn points
ReferralBox.earn_points(current_user, event: order)

# Redeem points
ReferralBox.redeem_points(current_user, offer: coupon)

# Check balance
ReferralBox.balance(current_user)

# Track referral
ReferralBox.track_referral(ref_code: params[:ref])
```

---

## 📬 Contribution

PRs are welcome 🙌 — help improve the gem or suggest features.

## 📜 License

MIT © 2025 Kapil Pal 