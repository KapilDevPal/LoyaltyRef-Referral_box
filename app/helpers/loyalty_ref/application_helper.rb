# frozen_string_literal: true

module LoyaltyRef
  module ApplicationHelper
    # Include LoyaltyRef JavaScript and configuration
    def loyalty_ref_javascript_tag
      return unless LoyaltyRef.configuration.enable_device_tracking
      
      config = {
        enabled: LoyaltyRef.configuration.enable_device_tracking,
        collect_geo: LoyaltyRef.configuration.collect_geo_location,
        api_endpoint: loyalty_ref_track_referral_path
      }
      
      content_tag(:script, "window.LoyaltyRefConfig = #{config.to_json};", type: 'application/javascript') +
      javascript_include_tag('loyalty_ref', 'data-turbolinks-track': 'reload')
    end

    # Generate a referral link with enhanced tracking
    def loyalty_ref_referral_link(user, options = {})
      return unless user.respond_to?(:referral_code) && user.referral_code.present?
      
      base_url = options[:base_url] || root_url
      ref_param = options[:ref_param] || 'ref'
      
      "#{base_url}#{base_url.include?('?') ? '&' : '?'}#{ref_param}=#{user.referral_code}"
    end

    # Generate a referral link button with styling
    def loyalty_ref_referral_button(user, text = nil, options = {})
      text ||= "Share Referral Link"
      link_text = options[:icon] ? "#{options[:icon]} #{text}" : text
      
      link_to(
        link_text,
        loyalty_ref_referral_link(user, options),
        options.merge(
          class: "loyalty-ref-referral-link #{options[:class]}".strip,
          target: options[:target] || '_blank',
          rel: options[:rel] || 'noopener'
        )
      )
    end

    # Display user's referral stats
    def loyalty_ref_user_stats(user)
      return unless user.respond_to?(:points_balance)
      
      content_tag(:div, class: 'loyalty-ref-user-stats') do
        concat(content_tag(:div, "Points: #{user.points_balance}", class: 'points'))
        concat(content_tag(:div, "Tier: #{user.current_tier || 'None'}", class: 'tier'))
        concat(content_tag(:div, "Referrals: #{user.total_referrals rescue 0}", class: 'referrals'))
      end
    end
  end
end 