module Cloudcrypt
    class SymmetricalCrypt
    SYMMETRICAL_ALGORITHM='aes-256-cbc'
    
    attr_reader :random_key, :random_iv
     def initialize(source_file,destination_file)
         @source_file = source_file
         @destination_file = destination_file
         raise "#{@source_file} file doesn't exist" unless File.exists?(@source_file)
         raise "#{@destination_file} Already Exists" if File.exists?(@destination_file)
         
         @cipher = OpenSSL::Cipher::Cipher.new(SYMMETRICAL_ALGORITHM)
     end
         
     def encrypt
         @cipher.encrypt # We are encypting
         # The OpenSSL library will generate random keys and IVs
         @random_key = @cipher.random_key
         @random_iv = @cipher.random_iv
         @cipher.key = @random_key
         @cipher.iv = @random_iv
         write_to_disk
     end
     
     def decrypt(key,iv)
         raise if ( key.empty? || iv.empty?)
         @cipher.decrypt # We are encypting
         @cipher.key = key
         @cipher.iv = iv
         write_to_disk
     end
 
    private   
     def write_to_disk
         # To improve performance the file is not store into memory        
         File.open(@destination_file,'wb') { |f|
             f << @cipher.update(File.open(@source_file,'rb').read)
             f << @cipher.final
         }
     end
    end
end