require 'set'

module SafeCredentials
  module HashQuery

    def query(path, subhash = self, prefix = nil)
      all_subpaths(path, subhash, prefix).find_all { |k| File.fnmatch?(path.gsub('.', '/'), k.gsub('.', '/')) }
    end

    def all_subpaths(path = '*', subhash = self, prefix = nil)
      parts = path.split('.')
      first_part = parts.shift

      matching_pathes = subhash.keys

      subpaths = matching_pathes.collect do |subpath|
        if Hash === subhash[subpath]
          new_prefix = [prefix, subpath].compact.join('.')
          all_subpaths(parts.join('.'), subhash[subpath], new_prefix)
        else
          [prefix, subpath].join('.')
        end
      end

      Set.new(subpaths).flatten
    end
  end
end