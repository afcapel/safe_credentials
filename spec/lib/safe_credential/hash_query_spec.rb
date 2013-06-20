require 'spec_helper'

describe SafeCredentials::HashQuery do

  before :each do
    @hash = {
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

    @hash.extend SafeCredentials::HashQuery
  end

  it "can query paths without glob expressions" do
    @hash.query('production.database.adapter').should == ['production.database.adapter']
  end

  it "can query matching using glob expressions" do
    @hash.query('*.database.db_*').should =~ [
      'development.database.db_password', 'development.database.db_user',
      'production.database.db_password',  'production.database.db_user'
    ]

    @hash.query('**.*password').should =~ [
      'development.password', 'development.database.db_password',
      'production.password',  'production.database.db_password'
    ]
  end
end