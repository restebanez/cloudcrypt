module Cloudcrypt

    class AsymmetricalCrypt
        def self.encrypt(public_key,data_to_encrypt)
            raise if ( public_key.empty? || data_to_encrypt.empty? )      
            public_key_rsa = OpenSSL::PKey::RSA.new(public_key)
            encrypted_data = public_key_rsa.public_encrypt(data_to_encrypt)
        end
        
        def self.decrypt(private_key,data_to_dencrypt)
            raise if ( private_key.empty? || data_to_dencrypt.empty?)
            private_key_rsa = OpenSSL::PKey::RSA.new(private_key)
            decrypted_data = private_key_rsa.private_decrypt(data_to_dencrypt)
        end
    end

end