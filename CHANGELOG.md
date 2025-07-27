# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.8] - 2025-01-XX

### Added
- **Interactive Generator**: Generator now asks for model name and confirms the choice
- **Model Detection**: Automatically detects existing models in the app
- **Safe Migrations**: Migration now checks if columns exist before adding them
- **Duplicate Prevention**: Prevents adding duplicate columns and methods

### Fixed
- **Migration Errors**: Fixed "duplicate column name" errors by adding existence checks
- **Generator Flow**: Improved user experience with interactive prompts
- **Model Flexibility**: Better support for different model names (User, Customer, Account, etc.)

## [0.1.7] - 2025-01-XX

### Added
- **Admin Dashboard Views**: Added all missing view templates for the admin dashboard
- **Dashboard Index**: Overview with statistics, recent transactions, and top users
- **Users List**: Complete user management with points, tiers, and referral codes
- **User Details**: Individual user profiles with transaction history
- **Transactions**: Full transaction history with filtering and pagination
- **Referrals**: Referral tracking with device and browser analytics
- **Analytics**: Comprehensive analytics with device breakdown and daily trends

### Fixed
- **Missing Templates**: Resolved "ActionController::MissingExactTemplate" error
- **Dashboard Navigation**: All dashboard sections now have proper views

## [0.1.5] - 2025-01-XX

### Fixed
- **Dynamic Migration Versioning**: Generator now creates migrations with correct Rails version format for any Rails version
- **Gemspec Dependencies**: Fixed Rails dependency constraints to use proper version format
- **Migration Compatibility**: Ensured all migrations work with Rails 6.0 through Rails 8.x

### Improved
- **Version Detection**: Enhanced Rails version detection in generator
- **Cross-Version Support**: Better support for different Rails versions

## [0.1.4] - 2025-01-XX

## [0.1.3] - 2025-01-XX

## [0.1.2] - 2025-01-XX

### Fixed
- **Migration Issue**: Fixed NOT NULL constraint error by making referrer_id nullable
- **Generator Improvements**: Removed interactive prompts, now reads configuration from initializer
- **Model Flexibility**: Generator automatically detects and uses the configured model class name
- **Migration Generation**: Creates proper migrations with correct table names and constraints

### Changed
- Generator no longer asks questions - uses `reference_class_name` from initializer
- Migration adds `null: true` to referrer_id to prevent constraint violations
- Added unique index on referral_code column

## [0.1.1] - 2025-01-XX

### Fixed
- Rails compatibility: Updated dependencies to support Rails 8.x and newer versions
- Removed restrictive version constraints on Rails, ActiveRecord, ActionView, and ActionPack

## [0.1.0] - 2025-01-XX

### Added
- Initial release of ReferralBox gem
- Points system with customizable earning/redeem rules
- Dynamic tier levels (Silver, Gold, Platinum)
- Unique referral codes and multi-level tracking
- Built-in tracking for signups, geo, device (no Redis needed)
- Admin dashboard with ERB views
- Support for any user model (User, Customer, Account, etc.)
- Rails generator for easy installation
- Comprehensive configuration system
- Transaction logging and analytics
- Referral sharing with full analytics
- Points expiration system
- Tier change callbacks
- Device and browser detection
- Conversion rate tracking 