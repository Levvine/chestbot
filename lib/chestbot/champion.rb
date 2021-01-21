require 'cgi'
require 'uri'
require 'net/http'


module ChestBot

  # Represents a Champion object, and contains methods that pertain to
  # champion data.
  class Champion

    @@ids
    @@filename = 'champion.json'

    def self.ids
      @@ids
    end

    def self.filename
      @@filename
    end

    # Parses championids.json
    # Called by patcher to reload the file after updating
    # @return [Hash] parsed
    def self.reload
      file = File.read(@@filename)
      json = JSON.parse(file)
      @@id = parse_ids(json['data'])
    end

    def self.parse_ids(champions)
      hash = {}
      champions.each do |c|
        hash[c[1]['name']] = c[1]['key'].to_i
      end
      # sorting hash is unnecessary because it's an internal data structure
      # hash = hash.sort.to_h
      return hash
    end

    # Converts a champion name to its id
    # @param [String] the champion's name
    # @return [Integer] returns champion id
    def self.getChampId(name)
      return @@id[name]
    end

    # Converts a champion id to its name
    # @param [Integer] the champion's id
    # @return [String] Given a champion id, return the champions name
    def self.getChampName(id)
      return @@id.key(id)
    end

  end

end
