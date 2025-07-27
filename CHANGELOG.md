# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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