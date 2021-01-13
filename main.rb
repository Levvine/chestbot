require_relative 'lib/chestbot'


botToken = ENV['BOT_TOKEN_CHESTBOT']
riotKey = ENV['RIOT_KEY']
#puts "bot token: #{botToken}"

# creates new bot
chestBot = ChestBot::Liaison.new(botToken, riotKey)

# shuts down bot
at_exit do
  puts "Bot is shutting down."
  chestBot.stop
end

chestBot.run false
