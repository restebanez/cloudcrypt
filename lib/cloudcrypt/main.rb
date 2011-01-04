module Cloudcrypt

    class Main
    
        ENCRYPTED_FILE_EXTENSION='.encrypted'
        ENCRYPTED_VI_EXTENSION='.vi'
        ENCRYPTED_KEY_EXTENSION='.key'

        
        if RUBY_PLATFORM.downcase.include?("mingw32") 
            TMP=ENV['TMP']
            FILE_SEPARATOR="\\" 
        else
            TMP='/tmp'
            FILE_SEPARATOR='/'
        end

        attr_reader :dst_encrypted_file, :dst_encrypted_key_file, :dst_encrypted_iv_file, :dst_unencrypted_file, :dst_zip_file
        
        def initialize(public_key_file,private_key_file=nil)
            @public_key_file = public_key_file
            @private_key_file = private_key_file
            


        end
        
        def encrypt(file_path,dst=TMP)
            raise_unless_exists(@public_key_file)
            public_key = File.read(@public_key_file)
            
            file_basename=File.basename(file_path) #gets the filename without the extension
            file_uri = dst + FILE_SEPARATOR + file_basename
            @dst_encrypted_file = file_uri + ENCRYPTED_FILE_EXTENSION       
            @dst_encrypted_key_file = raise_if_exists(file_uri + ENCRYPTED_KEY_EXTENSION)
            @dst_encrypted_iv_file = raise_if_exists(file_uri + ENCRYPTED_VI_EXTENSION)
            
            s=SymmetricalCrypt.new(file_path,@dst_encrypted_file)
            s.encrypt
            
            File.open(@dst_encrypted_key_file,'wb') {|f|
                   f << AsymmetricalCrypt.encrypt(public_key,s.random_key)
             }
    
            File.open(@dst_encrypted_iv_file,'wb') {|f|
                   f << AsymmetricalCrypt.encrypt(public_key,s.random_iv)
             }
             @dst_zip_file = file_path + '.zip'
             zip(@dst_zip_file, [@dst_encrypted_file,@dst_encrypted_key_file,@dst_encrypted_iv_file])
             File.delete(@dst_encrypted_file,@dst_encrypted_key_file,@dst_encrypted_iv_file)
             
        end
        
        def decrypt(file_path_zip,dst=TMP)
            unzip(file_path_zip,dst)
            
            raise_unless_exists(@private_key_file)
            private_key = File.read(@private_key_file)
            
            # where files where extracted from the zip file
            dir_basename = dst
            # gets the filename without the extension .zip
            file_basename = File.basename(file_path_zip,'.zip') 
            
            
            # Where to look for key and iv files
            file_uri = dir_basename + FILE_SEPARATOR + file_basename
            source_encrypted_file = raise_unless_exists(file_uri + ENCRYPTED_FILE_EXTENSION)
            source_encrypted_key_file = raise_unless_exists(file_uri + ENCRYPTED_KEY_EXTENSION)
            source_encrypted_iv_file = raise_unless_exists(file_uri + ENCRYPTED_VI_EXTENSION)
            @dst_unencrypted_file = dst + '/' + file_basename
            
            iv = AsymmetricalCrypt.decrypt(File.read(@private_key_file),File.open(source_encrypted_iv_file,'rb').read)
            key = AsymmetricalCrypt.decrypt(File.read(@private_key_file),File.open(source_encrypted_key_file,'rb').read)
            
            s = SymmetricalCrypt.new(source_encrypted_file,@dst_unencrypted_file)
            s.decrypt(key,iv)
            #windows thinks it's opened
            #File.delete(source_encrypted_file,source_encrypted_key_file,source_encrypted_iv_file)
        end
        
    
        
        def zip(new_zip_file,files=[])
            Zip::ZipFile.open(new_zip_file,Zip::ZipFile::CREATE) do |zip|
                files.each do |file|
                    file_basename = File.basename(file)
                    zip.file.open(file_basename,'wb') {|f|f << File.open(file,'rb').read }
                end
            end
        end
        
        def unzip(file_zip,dst=TMP)
            Zip::ZipFile.open(file_zip) do |zip|
                zip.each do |f|
                    f_path=File.join(dst, f.name)
                    #Chef::Log.info(f_path)
                    FileUtils.mkdir_p(File.dirname(f_path)) unless File.directory?(f_path)
                    zip.extract(f, f_path) unless File.exist?(f_path)
                end
            end     
        end
        
        def md5(file)
            return false unless File.exists?(file)
            return Digest::MD5.hexdigest(File.read(file))
        end
        
        def self.is_mac?
          # universal-darwin9.0 shows up for RUBY_PLATFORM on os X leopard with the bundled ruby. 
          # Installing ruby in different manners may give a different result, so beware.
          # Examine the ruby platform yourself. If you see other values please comment
          # in the snippet on dzone and I will add them.
            RUBY_PLATFORM.downcase.include?("darwin")
        end

        def self.is_windows?
            RUBY_PLATFORM.downcase.include?("mingw32")
        end
        
    private
    
        
        def raise_if_exists(file)
            raise "#{file} doesn't exist" if File.exists?(file) 
            file        
        end
        
        def raise_unless_exists(file)
            raise "#{file} doesn't exist" unless File.exists?(file)
            file
        end
    end
end