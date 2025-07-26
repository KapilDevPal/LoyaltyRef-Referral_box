# frozen_string_literal: true

module ReferralBox
  module DashboardHelper
    def referral_box_paginate(collection)
      if defined?(Kaminari) && collection.respond_to?(:current_page)
        paginate(collection)
      else
        # Simple pagination without Kaminari
        render_simple_pagination(collection)
      end
    end

    private

    def render_simple_pagination(collection)
      return unless collection.respond_to?(:limit_value) && collection.respond_to?(:offset_value)
      
      current_page = (collection.offset_value / collection.limit_value) + 1
      
      # For fallback pagination, we need to get total count differently
      # Since we don't have total_count method, we'll just show basic navigation
      content_tag(:div, class: 'pagination') do
        links = []
        
        # Previous page
        if current_page > 1
          links << link_to('Previous', url_for(page: current_page - 1), class: 'pagination-link')
        end
        
        # Current page
        links << content_tag(:span, "Page #{current_page}", class: 'pagination-current')
        
        # Next page (we'll always show this for fallback)
        links << link_to('Next', url_for(page: current_page + 1), class: 'pagination-link')
        
        links.join.html_safe
      end
    end
  end
end 