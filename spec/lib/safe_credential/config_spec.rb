require 'spec_helper'

describe SafeCredentials::Config do

  let(:config_file) { File.expand_path('../../../fixtures/config.yml', __FILE__)}
  let(:encrypted_config_file) { File.expand_path('../../../fixtures/encrypted_config.yml', __FILE__)}

  let(:config)   { SafeCredentials::Config.new(config_file, 'Super secret password') }




  it "can save encrypted config file" do
    orig_dev_env  = deep_copy(config['development'])
    orig_test_env = deep_copy(config['test'])
    orig_prod_env = deep_copy(config['production'])

    config.encrypt!

    config.save

    loaded_config = SafeCredentials::Config.load_encrypted('Super secret password', encrypted_config_file)

    loaded_config['development'].should == orig_dev_env
    loaded_config['production'].should  == orig_prod_env
    loaded_config['test'].should        == orig_test_env
  end

  def deep_copy(hash)
    Marshal.load(Marshal.dump(hash))
  end
end