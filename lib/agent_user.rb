# encoding: UTF-8

class AgentUser
  attr_reader :browser_name, :browser_version
  attr_reader :operating_system_name, :operating_system_version
  attr_reader :mobile_device_name, :mobile_device_version
  attr_reader :bot_name, :bot_version
  
  def initialize (str = "")
    
    # Device/Browser/OS name version pairs
    name_version_pairs = str.scan %r`((?:[-.a-zA-Z]+\s?)+)[/. ]((?:(?:DBN)|[xi0-9._-])+)`
    
    # Strip blacklisted names from name_version_pairs
    blacklist = 
      %w:.NET Mozilla Trident RTC InfoPath AppleWebKit chromeframe FlipboardProxy
      Gecko Media\ Center\ PC AskTbORJ Windows-Media-Player MSOffice:
    name_version_pairs = name_version_pairs.reject do |name, version|
      blacklist.any? {|n| name =~ /#{n}/i}
    end
    
    @operating_system_name, @operating_system_version = self.get_operating_system_data(name_version_pairs)
    @browser_name, @browser_version = self.get_browser_data(name_version_pairs)
    @mobile_device_name, @mobile_device_version = self.get_mobile_data(name_version_pairs)
    @bot_name, @bot_version = self.get_bot_data(name_version_pairs)
    
    return true
  end
  
  
  def to_s
    user_agent_data = []
    user_agent_data << "OS: #{self.operating_system_name} #{self.operating_system_version}" if self.operating_system_name
    user_agent_data << "Browser: #{self.browser_name} #{self.browser_version}" if self.browser_name
    user_agent_data << "Mobile: #{self.mobile_device_name} #{self.mobile_device_version}" if self.mobile_device_name
    user_agent_data << "Bot: #{self.bot_name} #{self.bot_version}" if self.bot_name
    puts user_agent_data.join(", ")
  end
  
  
  
  # Parse out operating system name and version
  def get_browser_data(name_version_pairs)
    
    # Filter our browser name and version based on user agent browser names
    b_names = %w:Safari Firefox MSIE IEMobile Opera Internet\ Explorer Chrome:
    b_name, b_version = name_version_pairs.find do |name, version|
      b_names.any? {|b_name| name =~ /#{b_name}/}
    end
    
    # Change MSIE to Internet Explorer
    b_name = 'Internet Explorer' if b_name == 'MSIE'
    
    # Change underscores to periods in b_version
    b_version = b_version.gsub(?_,?.) if b_version
    
    # The version number for Safari or Mobile Safari is located in another
    # place in the user agent. This will solve that by finding that version number
    version_arr = name_version_pairs.find {|name,version| name == "Version"}
    if b_name =~ /Safari/ && version_arr
      b_version = version_arr[1]
    end
    
    
    
    return b_name, b_version
  end
  
  # Parse out operating system name and version
  def get_operating_system_data (name_version_pairs)
    
    # NOTE: Reverse order of name_version_pairs to that Android and Ubuntu are
    #   found before Linux is if they exist in the name_version_pairs array.
    os_names = %w:Windows Android Ubuntu Linux CPU\ iPhone\ OS CPU\ OS Mac\ OS:
    os_name, os_version = name_version_pairs.reverse.find do |name, version|
      os_names.any? {|os_name| name =~ /#{os_name}/}
    end
    
    # Change underscores to periods in os_version
    os_version = os_version.gsub(?_,?.) if os_version
    
    # Change name from user agent to iOS if from an iPad or iPhone
    os_name = 'iOS' if ['CPU OS','CPU iPhone OS'].include?(os_name)
    os_name = 'Windows' if os_name == 'Windows NT'
    
    # Handle Windows version numbers/names
    if os_name == 'Windows'
      os_version = case os_version
      when '6.2'
        '8'
      when '6.1'
        '7'
      when '6.0'
        'Vista'
      when '5.2'
        'XP x64'
      when '5.1'
        'XP'
      when '5.0'
        '2000'
      when '4.1'
        '98'
      when '4.9'
        'ME'
      when '4.0'
        '95'
      end
    end
    
    
    
    return os_name, os_version
  end
  
  # Parse out mobile device name and version
  def get_mobile_data(name_version_pairs)
    
    # Mobile device name and version
    m_names = %w:Android Tablet Blackberry iPhone\ OS Zune CPU\ OS Windows\ Phone\ OS:
    m_name, m_version = name_version_pairs.find do |name, version|
      m_names.any? {|m_name| name =~ /#{m_name}/}
    end
    
    # Change underscores to periods in m_version
    m_version = m_version.gsub(?_,?.) if m_version
    
    m_name = 'iPad' if m_name == 'CPU OS'
    m_name = 'iPhone' if m_name == 'CPU iPhone OS'
    
    
    
    return m_name, m_version
  end
  
  
  
  # Parse out bot name and version
  def get_bot_data(name_version_pairs)
    
    # Bot name and version
    bot_names = %w:bot google bing yahoo:
    bot_name, bot_version = name_version_pairs.find do |name, version|
      bot_names.any? {|bot_name| name =~ /#{bot_name}/i}
    end
    
    # Change underscores to periods in m_version
    bot_version = bot_version.gsub(?_,?.) if bot_version
    
    
    
    return bot_name, bot_version
  end
  
  
  
  # Check if AgentUser detects a mobile device
  def mobile?
    !!self.mobile_device_name
  end
  
  # Check if AgentUser detects a bot
  def bot?
    !!self.bot_name
  end
end
