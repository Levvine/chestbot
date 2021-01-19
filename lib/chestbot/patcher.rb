require 'discordrb'

module ChestBot

  class Patcher

    # Creates a new patcher instance
    # patcher checks at a set time if there is a new version of data dragon
    # available and updates manifest and other libraries accordingly.
    def initialize

      # the time at which patching occurs (24H format)
      @patch_hour = 12
      @patch_minute = 00

      # loads variables from manifest.json
      load_manifest
    end

    attr_reader :manifest
    attr_reader :current_version

    def self.filename
      return "manifest.json"
    end

    # Data Dragon routing value
    def self.routing_value
      return "https://ddragon.leagueoflegends.com"
    end

    # Loads manifest.json if it exists, creates it if not
    # sets current_version
    def load_manifest
      if !File.exist?(self.class.filename)
        Discordrb::LOGGER.info("Manifest file is missing, generating from scratch.")
        update
      else
        manifest_file = File.new(self.class.filename)
        @manifest = JSON.parse(manifest_file.read)
        @current_version = Gem::Version.new(@manifest['version'])
      end
      return @manifest
    end

    def latest_version
      request = "/api/versions.json"
      uri = URI(self.class.routing_value + request)
      version_str = JSON.parse(Net::HTTP.get(uri))[0]
      return Gem::Version.new(version_str)
    end

    # Checks if updates are available and updates files
    # First ensures that @current_version matches @latest_version
    def update
      if @current_version == nil or @current_version < latest_version
        @manifest = {version: latest_version}
        manifest_file = File.new(self.class.filename, 'w')
        manifest_file.write JSON.pretty_generate(@manifest)
        manifest_file.close

        # reloads manifest after finishing write
        load_manifest
      else
        Discordrb::LOGGER.debug("No new updates found.")
      end
    end

    # Creates a thread that checks for patches
    def run_async
      @thread = Thread.new do
        Thread.current[:discordrb_name] = 'patcher'

        # Calculates delay before initial patch
        # if current time has passed patch time, find the next occurrence
        time = Time.now
        offset = time.change(hour: @patch_hour, min: @patch_minute, sec: 0) - time
        offset += 24.hours if offset.negative?
        Discordrb::LOGGER.debug("Initial patch scheduled for #{time + offset}")
        sleep offset

        # Checks for patch
        loop do
          Discordrb::LOGGER.debug("Checking for updates to Data Dragon.")
          update
          sleep 1.day
        rescue StandardError => e
          Discordrb::LOGGER.error('An error occurred while patching!')
        end
      end
    end

  end

end
