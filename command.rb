require_relative 'lib/chestbot'

module Discordrb

  class Command

    botToken = ENV['BOT_TOKEN_CHESTBOT']
    url = "https://discord.com/api/v8/applications/493218711868669954/guilds/793239019130585108/commands"
    filename = "commands.json"
    json = File.read(filename)

    headers = "Bot #{botToken}"

    attributes = [url, headers]

    RestClient.send(:post, url, json, {Authorization: headers, content_type: :json})

  end

end
