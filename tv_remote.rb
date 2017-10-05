require "bundler/setup"
require "serialport"
require "timeout"

class TvRemote
  # port identifier
  PORT = "/dev/ttyUSB0"

  CHANNELS = {
    apple_tv: 2,
    statusdroid: 3
  }.freeze

  CMD_POWER = "ka"
  CMD_INPUT = "xb"
  POLL = "ff"

  def power_on
  	send_command CMD_POWER, "01"
  end

  def power_off
  	send_command CMD_POWER, "00"
  end

  def select_channel(channel)
    channel_nr = CHANNELS.fetch(channel){ raise "Unknown channel '#{channel}'!"}
  	send_command CMD_INPUT, "a#{channel_nr}"
  end
  
  def read_current_channel
  	result = send_command CMD_INPUT, POLL
    result ? CHANNELS.invert[result[8].to_i] : nil
  end
  
  private
  
  def send_command(command, data)
    with_serial_port do |sp|
    	sp.write "#{command} 01 #{data}\r"
      if data == POLL
        Timeout::timeout(0.5) do
          sleep 0.1 until (result = sp.gets("x"))
          return result
        end
      end
    end
  rescue Timeout::Error
    #  Timeout means most probably that the TV is turned off.
    nil
  end

  def with_serial_port
  	sp = SerialPort.new(PORT, 9600)
	  sp.read_timeout = 1000
    yield sp
  ensure
    sp.close
  end
end
