#!/usr/bin/env ruby
# you can't use require 'cloudcrypt' 
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib', 'cloudcrypt'))

RAVE_BUCKET='ec2admin-software-installation-rave-5.6.3'
ENCRYPTED_FILE_EXTENSION='.encrypted'
ENCRYPTED_VI_EXTENSION='.vi'
ENCRYPTED_KEY_EXTENSION='.key'

unless ARGV.empty?
    def is_mac?
      # universal-darwin9.0 shows up for RUBY_PLATFORM on os X leopard with the bundled ruby. 
      # Installing ruby in different manners may give a different result, so beware.
      # Examine the ruby platform yourself. If you see other values please comment
      # in the snippet on dzone and I will add them.
        RUBY_PLATFORM.downcase.include?("darwin")
    end
    
    def is_windows?
        RUBY_PLATFORM.downcase.include?("mingw32")
    end
    
    if is_mac?
        # MAC
        PUBLIC_KEY='/Users/restebanez/id_nodemanager.pub'
        PRIVATE_KEY='/Users/restebanez/id_nodemanager'
        TMP='/tmp'
    elsif is_windows?
    
        # Windows
        PUBLIC_KEY='C:\Users\Administrator\.chef\id_nodemanager'
        PRIVATE_KEY='C:\Users\Administrator\.chef\id_nodemanager'
        TMP=ENV['TMP']
        require 'win32/registry.rb'
        require 'Win32API'  
        if ENV['RAVE_RW_AWS_ACCESS_KEY_ID'].nil? || ENV['RAVE_RW_AWS_SECRET_ACCESS_KEY'].nil?
            puts "Let's set up some envioroment variables"
            puts "RAVE_RW_AWS_ACCESS_KEY_ID: "
            Win32::Registry::HKEY_CURRENT_USER.open('Environment', Win32::Registry::KEY_WRITE) do |reg|
              reg['RAVE_RW_AWS_ACCESS_KEY_ID'] = gets
            end
            puts "RAVE_RW_AWS_SECRET_ACCESS_KEY: "
            Win32::Registry::HKEY_CURRENT_USER.open('Environment', Win32::Registry::KEY_WRITE) do |reg|
              reg['RAVE_RW_AWS_SECRET_ACCESS_KEY'] = gets
            end
            # make environmental variables available immediately
            # http://stackoverflow.com/questions/190168/persisting-an-environment-variable-through-ruby
            SendMessageTimeout = Win32API.new('user32', 'SendMessageTimeout', 'LLLPLLP', 'L') 
            HWND_BROADCAST = 0xffff
            WM_SETTINGCHANGE = 0x001A
            SMTO_ABORTIFHUNG = 2
            result = 0
            SendMessageTimeout.call(HWND_BROADCAST, WM_SETTINGCHANGE, 0, 'Environment', SMTO_ABORTIFHUNG, 5000, result)
            abort('Open a new powershell session and run it again')
        end   
    else
        abort('OS not detectect!')
    end
    
    abort('Please set the variable RAVE_RW_AWS_ACCESS_KEY_ID and RAVE_RW_AWS_SECRET_ACCESS_KEY') if ENV['RAVE_RW_AWS_ACCESS_KEY_ID'].nil? || ENV['RAVE_RW_AWS_SECRET_ACCESS_KEY'].nil?
    
    AWS_ACCESS_KEY_ID=ENV['RAVE_RW_AWS_ACCESS_KEY_ID'].gsub(/\r?\n?/, "")
    AWS_SECRET_ACCESS_KEY=ENV['RAVE_RW_AWS_SECRET_ACCESS_KEY'].gsub(/\r?\n?/, "")
    
    
    
    
    
    params=ARGV
    cloudcrypt = Cloudcrypt::Parser.new
    
    cloudcrypt.parse
end