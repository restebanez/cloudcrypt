module Cloudcrypt

    class S3Transfer
        def initialize(aws_access_key_id,aws_secret_access_key)
            begin 
              #Gem.clear_paths
              require 'fog'
            rescue LoadError
              #Chef::Log.warn("Missing gem 'fog'")
            end
            @s3=Fog::AWS::Storage.new(
            	:aws_access_key_id=> aws_access_key_id,
            	:aws_secret_access_key => aws_secret_access_key
            )
            
        end
        
        def upload(file_uri,bucket=RAVE_BUCKET)
            file_basename = File.basename(file_uri)
            abort("S3://#{bucket}/#{file_basename} already exist") if file_exists?(file_basename,bucket)
            f=@s3.directories.get(bucket).files.new(:key => file_basename, :body=>File.open(file_uri,'rb').read)
            f.save
            f.etag
            File.delete(file_uri)
        end
        
        def md5(file_basename,bucket=RAVE_BUCKET)
            return false unless file_exists?(file_basename,bucket)
            return @s3.directories.get(bucket).files.get(file_basename).etag
        end
        
        def download(file_basename,destination,bucket=RAVE_BUCKET)
            abort("S3://#{bucket}/#{file_basename} doesn't exist") unless file_exists?(file_basename,bucket)
            File.open(destination,'wb') { |f| f << @s3.directories.get(bucket).files.get(file_basename).body }
        end
        
        def list(bucket=RAVE_BUCKET)
            @s3.directories.get(bucket).files
        end
        
        def delete(file_basename,bucket=RAVE_BUCKET)
            abort("S3://#{bucket}/#{file_basename} doesn't exist") unless file_exists?(file_basename,bucket)
            @s3.directories.get(bucket).files.get(file_basename).destroy
        end
        
     private
     
       def file_exists?(file_name,bucket=RAVE_BUCKET)
           @s3.directories.get(bucket).files.each do |f|
               return true if file_name == f.key
           end
           return false       
       end       
    end
    
end