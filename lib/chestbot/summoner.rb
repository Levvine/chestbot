module ChestBot

  # Represents a Summoner object, which stores information about summoners.
  class Summoner

    attr_reader :name
    attr_reader :profileIconId
    attr_reader :level
    attr_reader :region

    attr_reader :chests

    # overrides the return method for champions array
    # @return an array of champion names
    def champions
      array = []
      @champions.each do |champion|
        array << champion[:name]
      end
      return array
    end

    # Creates a new summoner object
    # @param client [Client] Requires a client object from the Lol library to call Riot API
    # @param name [String] Summoner name that will be searched in Riot API
    # @return [Boolean] True if summoner exists in Riot API
    def initialize(client: , name: "''")
      @client = client

      # workaround: each requests' region does not auto update when client region updates
      @client.summoner.region = @client.region
      @region = client.region.upcase
      client.summoner.region
      @champions = []
      begin
      summoner_struct = client.summoner.find_by_name(name)
      @name = summoner_struct.name
      @id = summoner_struct.id
      @level = summoner_struct.summoner_level
      @accountId = summoner_struct.account_id
      @profileIconId = summoner_struct.profile_icon_id
      return true # if summoner exists without error
      rescue Lol::NotFound => e
        puts e
      end
      return false # if there were errors
    end

    # Called when summoner data is not cached
    def lookup
      @chests = 0
      @champions = []

      # workaround: each requests' region does not auto update when client region updates
      @client.champion_mastery.region = @client.region
      mastery_struct = @client.champion_mastery.all(encrypted_summoner_id: @id)
      mastery_struct.each do |mastery|
        if mastery.chest_granted
          @chests += 1
          champHash={}
          champHash[:id] = mastery.champion_id
          champHash[:name] = ChestBot::Champion.getChampName(mastery.champion_id)
          @champions << champHash
        end
      end
      @champions.sort_by! do |champHash|
        champHash[:name]
      end
    end

  end

end
