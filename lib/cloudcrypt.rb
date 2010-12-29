require 'rubygems'
require 'openssl'
require 'fog'
require 'zip/zipfilesystem'

__DIR__ = File.dirname(__FILE__)

$LOAD_PATH.unshift __DIR__ unless
  $LOAD_PATH.include?(__DIR__) ||
  $LOAD_PATH.include?(File.expand_path(__DIR__))


require 'cloudcrypt/parser'
require 'cloudcrypt/main'
require 'cloudcrypt/asymmetrical_crypt'
require 'cloudcrypt/symmetrical_crypt'
require 'cloudcrypt/s3_transfer'

