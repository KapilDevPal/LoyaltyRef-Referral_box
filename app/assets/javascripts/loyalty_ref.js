// LoyaltyRef - Device Detection and Geo-location Collection
// This script automatically collects device and location data when users click referral links

(function() {
  'use strict';

  // Check if LoyaltyRef tracking is enabled
  if (typeof window.LoyaltyRefConfig === 'undefined' || !window.LoyaltyRefConfig.enabled) {
    return;
  }

  // Device detection
  function detectDevice() {
    const userAgent = navigator.userAgent.toLowerCase();
    
    // Device type detection
    let deviceType = 'desktop';
    if (/mobile|android|iphone|ipod|blackberry|windows phone/.test(userAgent)) {
      deviceType = 'mobile';
    } else if (/tablet|ipad/.test(userAgent)) {
      deviceType = 'tablet';
    }

    // Browser detection
    let browser = 'Other';
    if (userAgent.includes('chrome')) {
      browser = 'Chrome';
    } else if (userAgent.includes('firefox')) {
      browser = 'Firefox';
    } else if (userAgent.includes('safari') && !userAgent.includes('chrome')) {
      browser = 'Safari';
    } else if (userAgent.includes('edge')) {
      browser = 'Edge';
    } else if (userAgent.includes('opera')) {
      browser = 'Opera';
    }

    return {
      device_type: deviceType,
      browser: browser,
      screen_width: screen.width,
      screen_height: screen.height,
      viewport_width: window.innerWidth,
      viewport_height: window.innerHeight,
      language: navigator.language,
      platform: navigator.platform,
      cookie_enabled: navigator.cookieEnabled,
      online: navigator.onLine
    };
  }

  // Geo-location detection (if enabled and user consents)
  function detectLocation() {
    return new Promise((resolve) => {
      if (!window.LoyaltyRefConfig.collect_geo || !navigator.geolocation) {
        resolve(null);
        return;
      }

      navigator.geolocation.getCurrentPosition(
        function(position) {
          resolve({
            latitude: position.coords.latitude,
            longitude: position.coords.longitude,
            accuracy: position.coords.accuracy,
            timestamp: position.timestamp
          });
        },
        function(error) {
          console.log('LoyaltyRef: Geolocation not available or denied');
          resolve(null);
        },
        {
          enableHighAccuracy: false,
          timeout: 5000,
          maximumAge: 60000
        }
      );
    });
  }

  // Collect all device and location data
  async function collectDeviceData() {
    const deviceData = detectDevice();
    const locationData = await detectLocation();

    return {
      ...deviceData,
      geo_data: locationData,
      collected_at: new Date().toISOString()
    };
  }

  // Enhanced referral tracking
  function enhanceReferralTracking() {
    // Find all referral links
    const referralLinks = document.querySelectorAll('a[href*="?ref="], a[href*="&ref="]');
    
    referralLinks.forEach(link => {
      link.addEventListener('click', async function(e) {
        // Only enhance if it's a referral link
        if (!this.href.includes('ref=')) return;

        try {
          // Collect device and location data
          const deviceData = await collectDeviceData();
          
          // Store in sessionStorage for the next page load
          sessionStorage.setItem('loyalty_ref_device_data', JSON.stringify(deviceData));
          
          // Add a small delay to ensure data is stored
          setTimeout(() => {
            // Continue with normal link navigation
            return true;
          }, 100);
          
        } catch (error) {
          console.error('LoyaltyRef: Error collecting device data:', error);
        }
      });
    });
  }

  // Initialize when DOM is ready
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', enhanceReferralTracking);
  } else {
    enhanceReferralTracking();
  }

  // Make functions available globally for manual use
  window.LoyaltyRef = {
    detectDevice: detectDevice,
    detectLocation: detectLocation,
    collectDeviceData: collectDeviceData
  };

})(); 