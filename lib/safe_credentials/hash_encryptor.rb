module SafeCredentials
  class HashEncryptor
    attr_reader :name, :attributes

    def initialize(attributes, cipher)
      @attributes, @cipher = attributes, cipher
      @attributes.extend SafeCredentials::HashQuery
    end

    def encrypt_val(val)
      case val
      when String then @cipher.enc(val).strip
      when Hash then encrypt_hash(val)
      end
    end

    def encrypt_hash(h)
      Hash.new.tap do |encrypted|
        h.each do |k, v|
          encrypted["encrypted_#{k}"] = encrypt_val(v)
        end
      end
    end

    def decrypt_val(val)
      case val
      when String then @cipher.dec(val).strip
      when Hash then decrypt_hash(val)
      end
    end

    def decrypt_hash(h)
      Hash.new.tap do |decrypted|
        h.each do |k, v|
          key = k.sub(/^encrypted_/, '')
          decrypted[key] = decrypt_val(v) if v
        end
      end
    end

    def encrypt(path)
      encrypt_val(value_for(path))
    end

    def encrypt!(path)
      last_key, subhash = subhash_for(path)
      new_key = "encrypted_#{last_key}"

      val = subhash.delete(last_key)
      subhash[new_key] = encrypt_val(val) if val
    end

    def decrypt!(path)
      last_key, subhash = subhash_for(path)
      new_key = last_key.sub(/^encrypted_/,'')

      subhash[new_key] = decrypt_val(subhash.delete(last_key))
    end

    def encrypt_paths!(query)
      @attributes.query(query).each { |path| encrypt!(path) }
    end

    def decrypt_paths!(query)
      @attributes.query(query).each { |path| decrypt!(path) }
    end

    def value_for(path)
      parts = path.split('.')
      parts.inject(attributes) { |attrs, key| attrs[key] }
    end

    def subhash_for(path)
      parts    = path.split('.')
      last_key = parts.pop

      subhash = parts.inject(attributes) { |attrs, key| attrs[key] }

      [last_key, subhash]
    end
  end
end