require 'openssl'
require 'yaml'
require 'erb'

module SafeCredentials

  class Config
    attr_reader :path, :config_file, :envs

    def initialize(path = 'config/config.yml', password = nil)
      @path = File.expand_path(path)
      yaml_source = ERB.new(File.read(path)).result

      @cipher = Gibberish::AES.new(password)

      @attributes = YAML.load(yaml_source)
      @encryptor = HashEncryptor.new(@attributes, @cipher)
    end

    def [](env_name)
      @attributes[env_name.to_s]
    end

    def self.load_encrypted(password, path = 'config/encrypted_config.yml')
      config = new(path, password)
      config.decrypt!
      config

    rescue OpenSSL::Cipher::CipherError
      $stderr.puts "Wrong password!"
      exit -1
    end

    def encrypt!(paths = '*')
      @encryptor.encrypt_paths!(paths)

    rescue OpenSSL::Cipher::CipherError
      $stderr.puts "Wrong password!"
      exit -1
    end

    def decrypt!(paths = '**encrypted_*')
      @encryptor.decrypt_paths!(paths)

    rescue OpenSSL::Cipher::CipherError
      $stderr.puts "Wrong password!"
      exit -1
    end

    def save(file_name = nil)
      unless file_name
        basename = File.basename(@path)
        dirname  = File.dirname(@path)

        file_name = File.join(dirname, "encrypted_#{basename}")
      end

      File.write(file_name, @attributes.to_yaml)
    end
  end
end