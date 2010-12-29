module Cloudcrypt
    require 'trollop'

    class Parser

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
             
         end
    end
        
    
    def parse
     
         Trollop::die :upload, "must exist" unless File.exists?(@opts[:upload]) if @opts[:upload]
         
         
         m=Cloudcrypt::Main.new(@opts[:public_key],@opts[:private_key])
         s3=Cloudcrypt::S3Transfer.new(AWS_ACCESS_KEY_ID,AWS_SECRET_ACCESS_KEY)
         
         
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