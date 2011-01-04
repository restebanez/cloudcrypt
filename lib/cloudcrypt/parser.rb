module Cloudcrypt
    require 'trollop'

    class Parser
        # Windows

        HWND_BROADCAST = 0xffff
        WM_SETTINGCHANGE = 0x001A
        SMTO_ABORTIFHUNG = 2



        
        
    def initialize
        abort('use --help') if ARGV.empty?
         
         @opts = Trollop::options do
             
             version "1.0 Rodrigo Estebanez"
             banner <<-EOS
         This script administrates the files of a private S3 Bucket. You can upload,download and delete files. Files will be encrypted using a public key before uploading them, it will be decrypted them after downloading them. 
         
         Options:
         EOS
         
             opt :upload, "upload a file to S3 in an encrypted fashion", :type => String
             opt :download, "download a S3 file and decrypt it", :type => String
             opt :erase, "delete a S3 file", :type => String
             opt :list, "list files of the rave bucket"
         #   opt :destination, "where to write the file", :type => String
             opt :public_key, "public key location for encryption", :type => String, :default => PUBLIC_KEY 
             opt :private_key, "private key location for decryption", :type => String, :default => PRIVATE_KEY
             opt :windows_setup, "Set windows variables"
             
         end
    end
        
    
    def parse
     
         Trollop::die :upload, "must exist" unless File.exists?(@opts[:upload]) if @opts[:upload]
         if @opts[:windows_setup]
             if Cloudcrypt::Main.is_windows?
 
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
                      sendmessagetimeout = Win32API.new('user32', 'SendMessageTimeout', 'LLLPLLP', 'L') 

                      result = 0
                      sendmessagetimeout.call(HWND_BROADCAST, WM_SETTINGCHANGE, 0, 'Environment', SMTO_ABORTIFHUNG, 5000, result)
                      abort('Open a new powershell session and run it again')
                  end
             else
                 abort('This option only applies to Windows OS')
                 
             end
         end
         
        abort('Please set the variable RAVE_RW_AWS_ACCESS_KEY_ID and RAVE_RW_AWS_SECRET_ACCESS_KEY') if ENV['RAVE_RW_AWS_ACCESS_KEY_ID'].nil? || ENV['RAVE_RW_AWS_SECRET_ACCESS_KEY'].nil?
        aws_access_key_id=ENV['RAVE_RW_AWS_ACCESS_KEY_ID'].gsub(/\r?\n?/, "")
        aws_secret_access_key=ENV['RAVE_RW_AWS_SECRET_ACCESS_KEY'].gsub(/\r?\n?/, "")
        
         m=Cloudcrypt::Main.new(@opts[:public_key],@opts[:private_key])
         s3=Cloudcrypt::S3Transfer.new(aws_access_key_id,aws_secret_access_key)
         
         
         if @opts[:list]
             s3.list.collect {|file| printf("%s\t%iB\t%s\n", file.key,file.content_length,file.etag) }
         elsif @opts[:erase]
             s3.delete(@opts[:erase])
         elsif @opts[:upload]
             m.encrypt(@opts[:upload])
             s3.upload(m.dst_zip_file)
         else
             pwd = Dir.pwd
             dst = File.join(pwd,@opts[:download])
             abort("it already exists") if File.exists?(dst)
             s3.download(@opts[:download],dst)
             m.decrypt(dst,pwd)
             puts m.dst_unencrypted_file
         end
    end

    end
end