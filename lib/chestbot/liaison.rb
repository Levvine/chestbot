module ChestBot

  # Manages sending/receiving data between Riot and Discord API
  class Liaison

    # Creates a new chest bot with the given authentication data
    # @param botToken [String] The token for logging in as a Discord bot
    # @param riotKey [String] The API key used to access the Riot API
    def initialize(botToken, riotKey)
      @discordBot = Discordrb::Bot.new token: botToken, log_mode: :debug, fancy_log: true
      @lolClient = Lol::Client.new riotKey, region: 'na'

      # declare_message_command
      declare_chest_command
    end

    # see Discordrb::Bot#run
    def run (background = false)
      @discordBot.run background
    end

    # see Discordrb::Bot#stop
    def stop
      @discordBot.stop
    end

    # Creates a test message, usually disabled
    def declare_message_command
      @discordBot.message(with_text: 'test') do |event|
        event.respond 'test'
      end
    end

    # Creates a chest command event response
    def declare_chest_command
      @discordBot.application_command("chest") do |event|

        # workaround: discordrb interactions Member object does not include
        # IDObject mixin, therefore no timestamp method
        ms = (event.data['id'].to_i >> 22) + Discordrb::DISCORD_EPOCH
        timestamp = Time.at(ms / 1000.0)

        summonerName = event.options['summoner']
        @lolClient.region = event.options['region'] || 'NA'

        begin
          summoner = ChestBot::Summoner.new(client: @lolClient, name: summonerName)
        rescue Lol::InvalidAPIResponse => e
          puts e
          content = "There was a problem accessing the Riot API. The API key may "\
          "be expired."
          puts content
          event.reply content: content, show_source: true
        end

        if summoner.name # if it exists
          summoner.lookup # if not cached
          event.acknowledge(show_source: true)
          embed = createChestEmbed(summoner)
          event.channel.send_message("", false, embed)
        else
          event.reply(content: "Sorry, the requested summoner does not exist.", show_source: true)
        end
      end
    end

    # Creates a embed object that responds to declare_chest_command
    # @param summoner [Summoner] The summoner object that will be displayed in the embed
    def createChestEmbed(summoner)
      embed = Discordrb::Webhooks::Embed.new
      author = {name: "#{summoner.name} (#{summoner.region})  −  Level #{summoner.level}", icon_url: "http://ddragon.leagueoflegends.com/cdn/10.25.1/img/profileicon/#{summoner.profileIconId}.png"}
      embed.color = 0x00b5b5
      embed.author = Discordrb::Webhooks::EmbedAuthor.new(author)
      embed.description = "Obtained #{summoner.chests} chests"
      embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new(url: "http://raw.communitydragon.org/pbe/plugins/rcp-fe-lol-missions/global/default/reward_chest_double.png")
      # embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: "Chest Bot", icon_url: "https://cdn.discordapp.com/embed/avatars/0.png")
      # embed.timestamp = Time.at(timestamp)

      #if false
        fieldTitle = ""
        fieldValue = ""
        newLetter = true
        if summoner.champions.any?
          fieldTitle = summoner.champions[0].slice(0)
          col = 0
          summoner.champions.each do |champion|
            newLetter = !champion.slice(0).casecmp?(fieldTitle)
            if newLetter
              embed.add_field(name: fieldTitle, value: fieldValue, inline: true)
              fieldValue = ""
              fieldTitle = champion.slice(0).upcase
              newLetter = false
              col == 2 ? col = 0 : col += 1
            end
            fieldValue << "#{champion}\n"
          end
          embed.add_field(name: fieldTitle, value: fieldValue, inline: true)
          # left aligns columns in last group of rows
          embed.add_field(name: "\u200B", value: "\u200B", inline: true) if col == 1
        end
      # end
      return embed
    end

  end

end
