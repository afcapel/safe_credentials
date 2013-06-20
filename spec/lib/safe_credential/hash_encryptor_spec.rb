require 'spec_helper'

describe SafeCredentials::HashEncryptor do

  before :each do
    cipher = Gibberish::AES.new('abracadabra')

    @config = {
      'development' => {
        'user'     => 'wadus',
        'password' => 'secret',
        'database' => {
          'adapter'     => 'sqlite',
          'db_user'     => 'scott',
          'db_password' => 'tiger'
        }
      },
      'production' => {
        'user'     => 'admin',
        'password' => '1234',
        'database' => {
          'adapter'     => 'postgresql',
          'db_user'     => 'scott',
          'db_password' => 'tiger'
        }
      }
    }

    @hash_encryptor = SafeCredentials::HashEncryptor.new(@config, cipher)
  end

  it "can encrypt/decrypt a value" do
    encrypted = @hash_encryptor.encrypt_val('testing')
    encrypted.should_not == 'testing'
    @hash_encryptor.decrypt_val(encrypted).should == 'testing'
  end

  it "can encrypt/decrypt an env" do
    encrypted_env = @hash_encryptor.encrypt('development')

    encrypted_env['encrypted_user'].should_not be_nil
    encrypted_env['encrypted_password'].should_not be_nil

    encrypted_env['user'].should be_nil
    encrypted_env['password'].should be_nil

    decrypted_env = @hash_encryptor.decrypt_val(encrypted_env)

    decrypted_env['user'].should     == 'wadus'
    decrypted_env['password'].should == 'secret'
  end

  it "can find the value for a nested path" do
    @hash_encryptor.value_for('production.database').should == {
      'adapter'     => 'postgresql',
      'db_user'     => 'scott',
      'db_password' => 'tiger'
    }

    @hash_encryptor.value_for('production.database.db_password').should == 'tiger'
  end

  it "can encrypt/decrypt a nested path" do
    encrypted_db = @hash_encryptor.encrypt('production.database')

    encrypted_db['encrypted_db_user'].should_not be_nil
    encrypted_db['encrypted_db_password'].should_not be_nil

    encrypted_db['db_user'].should be_nil
    encrypted_db['db_password'].should be_nil

    decrypted_db = @hash_encryptor.decrypt_val(encrypted_db)

    decrypted_db.should == {
      'adapter'     => 'postgresql',
      'db_user'     => 'scott',
      'db_password' => 'tiger'
    }
  end

  it "can encrypt/decrypt an attribute within a nested path" do
    encrypted_password = @hash_encryptor.encrypt('production.database.db_password')
    encrypted_password.should_not == 'tiger'

    @hash_encryptor.decrypt_val(encrypted_password).should == 'tiger'
  end

  it 'can replace attributes in the hash with encrypted values' do
    original_development = @config['development'].dup

    @hash_encryptor.encrypt!('development')

    @config['encrypted_development']['encrypted_user'].should_not be_nil
    @config['encrypted_development']['encrypted_password'].should_not be_nil

    @config['encrypted_development']['user'].should be_nil
    @config['encrypted_development']['password'].should be_nil

    decrypted_env = @hash_encryptor.decrypt_val(@config['encrypted_development'])

    decrypted_env.should == original_development
  end

  it 'can deep replace attributes in the hash with encrypted values' do
    @hash_encryptor.encrypt!('production')

    @config['encrypted_production']['encrypted_user'].should_not be_nil
    @config['encrypted_production']['encrypted_password'].should_not be_nil
    @config['encrypted_production']['encrypted_database'].should_not be_nil
    @config['encrypted_production']['encrypted_database']['encrypted_db_user'].should_not be_nil
    @config['encrypted_production']['encrypted_database']['encrypted_db_password'].should_not be_nil

    @config['production'].should be_nil
    @config['encrypted_production']['database'].should be_nil

    decrypted_env = @hash_encryptor.decrypt_val(@config['encrypted_production'])

    decrypted_env.should == {
      'user'     => 'admin',
      'password' => '1234',
        'database' => {
          'adapter'     => 'postgresql',
          'db_user'     => 'scott',
          'db_password' => 'tiger'
        }
    }
  end

  it 'can match keys to replace against a glob expresion' do
    @hash_encryptor.encrypt_paths!('*.database.db_*')

    @config['development']['database']['adapter'].should == 'sqlite'
    @config['development']['database']['user'].should be_nil
    @config['development']['database']['password'].should be_nil
    @config['development']['database']['encrypted_db_user'].should_not be_nil
    @config['development']['database']['encrypted_db_password'].should_not be_nil

    @config['production']['database']['adapter'].should == 'postgresql'
    @config['production']['database']['user'].should be_nil
    @config['production']['database']['password'].should be_nil
    @config['production']['database']['encrypted_db_user'].should_not be_nil
    @config['production']['database']['encrypted_db_password'].should_not be_nil
  end
end