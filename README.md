# Safe Credentials

Safe Credentials allows you to encrypt sensitive credentials so you can
store your configuration files in source control.

## Motivation

To store configuration files in source control is always a tricky issue. You shouldn't
store your credentials in clear text in source control, but often your team needs a subset
of those credentials to test and execute the project.

A usual approach is to create a configuration file (config.yml or similar) but don't push it
to source control. Instead, you also create a dummy example file (config.yml.example) with dummy
values. When someone needs to access the real credentials he or she has to ask the project owner
for them.

This solution is not ideal, especially when you need to add add or change some configuration
parameter.

## Usage

Install the gem

```shell

$ gem install safe_credentials

```

Run the provided executable:

```shell

$ safe_credentials encrypt

  Encrypting file config/config.yml
  Enter your password:
  Result stored in config/encrypted_config.yml
  Adding config/config.yml to .gitignore.

```

Later, when you need to decrypt the credentials

```shell
$ bin/safe_credentials decrypt

  Decrypting file config/encrypted_config.yml
  Enter your password:
  Result stored in config/config.yml

```

## Options

Choose the path to the real config file and the encrypted one:

```shell

safe_credentials encrypt --from path/to/config.yml --to path/to/decrypted_config.yml

```

Also you can choose to encrypt only some configuration parameters:

```shell

# Encrypt database variables in all environments

safe_credentials encrypt --vars **.database.*

# Encrypt production variables

safe_credentials encrypt --vars producion

# Encrypt only password variables

safe_credentials encrypt --vars **password

```

## Credits

Original idea seen on [John Resig's blog](http://ejohn.org/blog/keeping-passwords-in-source-control/)

## TODO

* Capistrano integration. Upload config file to remote server and decrypt it there.
* Support other formats beside YAML, like TOML or JSON.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
