require 'dotenv'
Dotenv.load('../.env')
require 'discordrb'
require 'Lol'
require 'json'

require_relative 'chestbot/summoner'
require_relative 'chestbot/champion'
require_relative 'chestbot/liaison'


# All ChestBot functionality, to be extended by other files.
module ChestBot

end
