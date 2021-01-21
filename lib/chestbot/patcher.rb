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
      manifest_file = File.new(self.class.filename)
      @manifest = JSON.parse(manifest_file.read)
      @current_version = Gem::Version.new(@manifest['version'])
      @manifest['data'].each do |d|

        # loads relevant files into memory for dependant classes
        clazz = Object.const_get(d['class'])
        clazz.reload
      end
      Discordrb::LOGGER.debug("Data Dragon Patcher running on version #{@current_version}")
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

      # latest_version is an API request, so it is stored in variable remote
      # version to avoid requesting from the API multiple times
      remote_version = latest_version
      if @current_version < remote_version
        Discordrb::LOGGER.info("New version found! Starting update from version "\
          "#{@current_version} to #{remote_version}.")

        @manifest['data'].each do |d|

          # Using class name, requests data from url and transfers the result to
          # the file and corresponding variable, as defined in manifest.
          clazz = Object.const_get(d['class'])
          routing_value = d['routing_value']
          request = d['request'].gsub('#{version}', remote_version.to_s)
          puts uri = URI(routing_value + request)

          # Creates a file with the designated filename and records the result
          # obtained from the uri
          file = File.new(clazz.filename, 'w')
          IO.copy_stream(URI.open(uri), 'champion.json')
          Discordrb::LOGGER.info("Updated #{clazz.filename} for #{clazz}.")
        end

        @manifest['version'] = remote_version
        @current_version = Gem::Version.new(@manifest['version'])
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
