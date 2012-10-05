# encoding: UTF-8

class AgentUser
  attr_accessor :browser_name, :browser_version
  attr_accessor :operating_system_name, :operating_system_version
  attr_accessor :mobile_device_name, :mobile_device_version
  
  def initialize (str = "")
    
    @browser_name = 'Other'
    @browser_version = 'Other'
    @operating_system_name = 'Other'
    @operating_system_version = 'Other'
    @mobile_device_name = 'Other'
    @mobile_device_version = 'Other'
    
    # Every device/browser/os name with version
    name_version_pairs = str.scan %r`((?:[a-zA-Z]+\s?)+)[/ ]([xi0-9._]+)`
    
    self.get_operating_system_data(name_version_pairs)
    self.get_browser_data(name_version_pairs)
    self.get_mobile_data(name_version_pairs)
    
    return true
  end
  
  
  
  # Parse out operating system name and version
  def get_browser_data(name_version_pairs)
    # Filter our browser name and version based on user agent browser names
    b_names = %w|Mobile\ Safari Safari Firefox MSIE IEMobile bot Bot spider Spider Opera Internet\ Explorer Chrome|
    b_name, b_version = name_version_pairs.find do |name, version|
      b_names.any? {|b_name| name.include? b_name}
    end
    
    # Change MSIE to Internet Explorer
    b_name = 'Internet Explorer' if b_name == 'MSIE'
    
    # Change underscores to periods in b_version
    b_version = b_version.gsub(?_,?.) if b_version
    
    # The version number for Safari is located in another place in the user agent
    #   Below will solve that by finding that version number
    version_arr = name_version_pairs.select {|name,version| name == "Version"}.first
    if b_name == "Safari" && version_arr
      b_version = version_arr[1]
    end
    
    
    
    self.browser_name, self.browser_version = b_name, b_version
  end
  
  # Parse out operating system name and version
  def get_operating_system_data (name_version_pairs)
    # NOTE: Make sure Android is before Linux in os_names
    os_names = %w|Windows Android Linux CPU\ iPhone\ OS CPU\ OS bot Bot spider Spider Mac\ OS|
    os_name, os_version = name_version_pairs.find do |name, version|
      os_names.any? {|os_name| name.include? os_name}
    end
    
    # Change underscores to periods in os_version
    os_version = os_version.gsub(?_,?.) if os_version
    
    # Change name from user agent to iOS if from an iPad or iPhone
    os_name = 'iOS' if ['CPU OS','CPU iPhone OS'].include?(os_name)
    os_name = 'Bot' if !!(os_name =~ /bot/i)
    os_name = 'Spider' if !!(os_name =~ /spider/i)
    os_name = 'Windows' if os_name == 'Windows NT'
    
    # Handle Windows version numbers/names
    os_version = case os_name == 'Windows'
    when os_version == '6.2'
      '8'
    when os_version == '6.1'
      '7'
    when os_version == '6.0'
      'Vista'
    when os_version == '5.2'
      'XP x64'
    when os_version == '5.1'
      'XP'
    when os_version == '5.0'
      '2000'
    when os_version == '4.1'
      '98'
    when os_version == '4.9'
      'ME'
    when os_version == '4.0'
      '95'
    else
      'other'
    end
    
    
    
    self.operating_system_name, self.operating_system_version = os_name, os_version
  end
  
  # Parse out mobile device name and version
  def get_mobile_data(name_version_pairs)
    # Mobile device name and version
    m_names = %w|Android Blackberry iPhone\ OS Zune CPU\ OS Windows\ Phone\ OS|
    m_name, m_version = name_version_pairs.find do |name, version|
      m_names.any? {|m_name| name.include? m_name}
    end
    
    # Change underscores to periods in m_version
    m_version = m_version.gsub(?_,?.) if m_version
    
    m_name = 'iPad' if m_name == 'CPU OS'
    m_name = 'iPhone' if m_name == 'CPU iPhone OS'
    
    
    
    self.mobile_device_name, self.mobile_device_version = m_name, m_version
  end
  
  
  # Check if AgentUser detects a mobile device
  def mobile?
    !!self.mobile_device_name
  end
  
  
  # Check if AgentUser detects a bot
  def bot?
    !!(self.operating_system_name =~ /bot/i)
  end
end
