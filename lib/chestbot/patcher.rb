require 'discordrb'

module ChestBot

  class Patcher

    # Creates a new patcher instance
    def initialize
      # the time at which patching occurs (24H format)
      @patch_hour = 19
      @patch_minute = 26
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
          update
          sleep 1.day
        rescue StandardError => e
          Discordrb::LOGGER.error('An error occurred while patching!')
        end
      end
    end

    # Checks if updates are available and updates files
    # champIds.json
    def update
      Discordrb::LOGGER.debug("Checking for patch")
    end


  end

end
