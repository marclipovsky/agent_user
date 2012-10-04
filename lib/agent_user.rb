# encoding: UTF-8

module AgentUser
  class Parser
    
    def self.parse(str)
      self.new(str)
    end
    
    def initialize (str)
      # Every device/browser/os name with version
      all_names_and_versions_arr = str.scan %r`((?:[a-zA-Z]+\s?)+)[/ ]([0-9._]+)`
      
      self.get_operating_system_data(str)
      self.get_browser_data(all_names_and_versions_arr)
      self.get_mobile_data(all_names_and_versions_arr)
      
      return true
    end
    
    
    
    # Parse out operating system name and version
    def get_browser_data(all_names_and_versions_arr)
      # Filter our browser name and version based on user agent browser names
      names_and_versions_without_os_info = all_names_and_versions_arr.reject {|e| e == @os_name_and_version.last}
      browser_name_and_version = names_and_versions_without_os_info.select do |e|
        e.to_s.include?('Safari') ||
        e.to_s.include?('Mobile Safari') ||
        e.to_s.include?('Firefox') ||
        e.to_s.include?('MSIE') ||
        e.to_s.include?('IEMobile') ||
        e.to_s.include?('Opera') ||
        e.to_s.include?('Internet Explorer') ||
        e.to_s.include?('Chrome')
      end.first
      
      @browser_name, @browser_version = browser_name_and_version
      
      
      # The version number for Safari is located in another place in the user agent
      #   Below will solve that by finding that version number
      version_arr = names_and_versions_without_os_info.select {|e| e[0] == "Version"}.first
      if @browser_name == "Safari" && version_arr
        @browser_version = version_arr[1]
      end
    end
    
    # Parse out operating system name and version
    def get_operating_system_data (str)
      @os_name_and_version = str.scan %r`((?:\w+\s?)+)\s([0-9._]+)`
      @operating_system_name, @operating_system_version = @os_name_and_version.last
    end
    
    # Parse out mobile device name and version
    def get_mobile_data(all_names_and_versions_arr)
      # Mobile device name and version
      mobile_device_name_and_version = all_names_and_versions_arr.select do |e|
        e.to_s.include?('Android') ||       # Android
        e.to_s.include?('Blackberry') ||    # Blackberry
        e.to_s.include?('iPhone OS') ||     # iPhone
        e.to_s.include?('CPU OS') ||        # iPad
        e.to_s.include?('Windows Phone OS') # Windows Phone
      end.first
      
      @mobile_device_name, @mobile_device_version = mobile_device_name_and_version
    end
    
    
    
    def mobile?
      # Force true or false if the based on the device name
      !!@mobile_device_name
    end
    
    
    
    def mobile_device_name
      # Change name from user agent to more readable iOS device
      return 'iPad' if @mobile_device_name == 'CPU OS'
      return 'iPhone' if @mobile_device_name == 'CPU iPhone OS'
      
      @mobile_device_name
    end
    
    def mobile_device_version
      # Replace _ in some version numbers to .
      @mobile_device_version.gsub(?_,?.) if @mobile_device_version
    end
    
    def operating_system_name
      # Change name from user agent to iOS if from an iPad or iPhone
      return 'iOS' if ['CPU OS','CPU iPhone OS'].include? @operating_system_name
      
      @operating_system_name || 'Other'
    end
    
    def operating_system_version
      # Replace _ in some version numbers to .
      @operating_system_version.gsub(?_,?.) if @operating_system_version
    end
    
    def browser_name
      return 'Internet Explorer' if @browser_name == 'MSIE'
      
      @browser_name || 'Other'
    end
    
    def browser_version
      # Replace _ in some version numbers to .
      @browser_version.gsub(?_,?.) if @browser_version
    end
    
  end
end
