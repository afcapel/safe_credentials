require "thor"
require 'io/console'

class SafeCredentialsCLI < Thor

  desc "encrypt", "Encrypt configuration file"
  option :from, desc: 'source file to encrypt', default: 'config/config.yml'
  option :to, desc: 'target file', default: 'config/encrypted_config.yml'
  option :vars, desc: 'glob expression with the keys to encode', default: '*'
  def encrypt

    puts  "  Encrypting file #{options[:from]}"
    print "  Enter your password: "
    password = STDIN.noecho(&:gets)
    puts ''

    config = SafeCredentials::Config.new(options[:from], password)

    config.encrypt!(options[:vars])
    config.save(options[:to])

    puts "  Result stored in #{options[:to]}"
    add_to_gitignore(options[:from])
    puts  ""
  end

  desc "decrypt", "Decrypt configuration file"
  option :from, desc: 'source file to encrypt', default: 'config/encrypted_config.yml'
  option :to, desc: 'target file', default: 'config/config.yml'
  option :vars, desc: 'glob expression with the keys to decode', default: '**encrypted_*'
  def decrypt
    puts  ""
    puts  "  Decrypting file #{options[:from]}"
    print "  Enter your password: "
    password = STDIN.noecho(&:gets)
    puts ''

    config = SafeCredentials::Config.load_encrypted(password, options[:from])

    config.decrypt!(options[:vars])
    config.save(options[:to])

    puts "  Result stored in #{options[:to]}"
    add_to_gitignore(options[:to])
     puts  ""
  end


  private

  def add_to_gitignore(config_file)
    return unless File.exist?('.gitignore') && !File.read('.gitignore').match(config_file)

    puts "  Adding #{config_file} to .gitignore."

    File.open('.gitignore', 'a') do |f|
      f << "#{config_file}\n"
    end
  end
end