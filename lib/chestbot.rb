require 'dotenv'
Dotenv.load('../.env')
require 'discordrb'
require 'Lol'
#require 'net/http'
#require 'json'
require 'active_support'
require 'active_support/core_ext/numeric/time'

require_relative 'chestbot/summoner'
require_relative 'chestbot/champion'
require_relative 'chestbot/liaison'
require_relative 'chestbot/patcher'


# All ChestBot functionality, to be extended by other files.
module ChestBot

end
