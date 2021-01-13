require 'cgi'
require 'uri'
require 'net/http'


module ChestBot

  # Represents a Champion object, and contains methods that pertain to
  # champion data.
  class Champion

    # @deprecated Currently using a hardcoded json file, will be moved to
    # auto updater in the future
    def self.getLatestVersion
      request = "https://ddragon.leagueoflegends.com/api/versions.json"
      uri = URI(request)
      version = JSON.parse(Net::HTTP.get(uri))[0]
    end

    # Parses championids.json
    # @return [Hash] parsed
    def self.parseChampIdJson(fileName)
      if !File.exist?(fileName)
        champIdsFile = File.new(fileName,"w")
        version = self.getLatestVersion
        request = "https://ddragon.leagueoflegends.com/cdn/#{version}/data/en_US/champion.json"
        uri = URI(request)
        json = Net::HTTP.get(uri)
        response = JSON.parse(json)["data"]

        champIdHash = Hash.new
        response.each do |c|
          champIdHash[c[0]] = c[1]["key"].to_i
          puts c[1]["key"].to_i
        end
        champIdsFile.write(champIdHash.to_json)
        champIdHash
      else
        json = File.read(fileName)
        champIdHash = JSON.parse(json)
      end
    end

    # Converts a champion name to its id
    # @param [String] the champion's name
    # @return [Integer] returns champion id
    def self.getChampId(name)
      champIdHash = self.parseChampIdJson("champIds.json")
      champIdHash[name]
    end

    # Converts a champion id to its name
    # @param [Integer] the champion's id
    # @return [String] Given a champion id, return the champions name
    def self.getChampName(id)
      champIdHash = self.parseChampIdJson("champIds.json")
      champIdHash.key(id)
    end

  end

end
