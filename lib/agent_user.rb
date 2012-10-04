# encoding: UTF-8

class AgentUser
  
  def self.parse(str)
    self.new(str)
  end
  
  def initialize (str)
    # Every device/browser/os name with version
    @name_version_pairs = str.scan %r`((?:[a-zA-Z]+\s?)+)[/ ]([xi0-9._]+)`
    
    self.get_operating_system_data(@name_version_pairs)
    self.get_browser_data(@name_version_pairs)
    self.get_mobile_data(@name_version_pairs)
    
    return true
  end
  
  
  
  # Parse out operating system name and version
  def get_browser_data(arr)
    # Filter our browser name and version based on user agent browser names
    browser_names = %w|Mobile\ Safari Safari Firefox MSIE IEMobile bot Bot spider Spider Opera Internet\ Explorer Chrome|
    browser_name_and_version = arr.find do |name, version|
      browser_names.any? {|browser_name| name.include? browser_name}
    end
    
    @browser_name, @browser_version = browser_name_and_version
    
    
    # The version number for Safari is located in another place in the user agent
    #   Below will solve that by finding that version number
    version_arr = arr.select {|name,version| name == "Version"}.first
    if @browser_name == "Safari" && version_arr
      @browser_version = version_arr[1]
    end
  end
  
  # Parse out operating system name and version
  def get_operating_system_data (arr)
    # NOTE: Make sure Android is before Linux in browser_names
    operating_system_names = %w|Windows Android Linux CPU\ iPhone\ OS CPU\ OS bot Bot spider Spider Mac\ OS|
    os_name_and_version = arr.find do |name, version|
      operating_system_names.any? {|operating_system_name| name.include? operating_system_name}
    end
    
    @operating_system_name, @operating_system_version = os_name_and_version
  end
  
  # Parse out mobile device name and version
  def get_mobile_data(arr)
    # Mobile device name and version
    mobile_device_names = %w|Android Blackberry iPhone\ OS Zune CPU OS Windows\ Phone\ OS|
    mobile_device_name_and_version = arr.find do |name, version|
      mobile_device_names.any? {|mobile_device_name| name.include? mobile_device_name}
    end
    
    @mobile_device_name, @mobile_device_version = mobile_device_name_and_version
  end
  
  
  
  def mobile?
    # Force true or false if the based on the device name
    !!@mobile_device_name
  end
  
  
  def bot?
    !!(self.operating_system_name =~ /bot/i)
  end
  
  
  
  def mobile_device_name
    # Change name from user agent to more readable iOS device
    return 'iPad' if @mobile_device_name == 'CPU OS'
    return 'iPhone' if @mobile_device_name == 'CPU iPhone OS'
    
    @mobile_device_name
  end
  
  def mobile_device_version
    # Replace underscores in some version numbers to periods
    @mobile_device_version = @mobile_device_version.gsub(?_,?.) if @mobile_device_version
  end
  
  def operating_system_name
    # Change name from user agent to iOS if from an iPad or iPhone
    return 'iOS' if ['CPU OS','CPU iPhone OS'].include? @operating_system_name
    return 'Bot' if !!(@operating_system_name =~ /bot/i)
    return 'Spider' if !!(@operating_system_name =~ /spider/i)
    
    @operating_system_name || 'Other'
  end
  
  def operating_system_version
    # Replace underscores in some version numbers to periods
    @operating_system_version = @operating_system_version.gsub(?_,?.) if @operating_system_version
  end
  
  def browser_name
    return 'Internet Explorer' if @browser_name == 'MSIE'
    
    @browser_name || 'Other'
  end
  
  def browser_version
    # Replace underscores in some version numbers to periods
    @browser_version = @browser_version.gsub(?_,?.) if @browser_version
  end
  
end
