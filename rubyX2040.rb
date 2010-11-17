#!/usr/bin/ruby
# Ruby interface to the Pertelian X2040 LCD Display

require 'rubygems'
require 'serialport'

WRITE_DELAY = 0.003  # Number of seconds to wait between character bytes.
INSTRUCTION_DELAY = 0.01  # Number of seconds to wait between instruction bytes.
ROW_WIDTH = 20  # Number of characters that will fit on a line.
ROW_OFFSETS = [0x00, 0x40, 0x14, 0x54]  # Offsets for ordering rows correctly.

class Pertelian
  def initialize(tty='/dev/ttyUSB0')
    @sp = SerialPort.new tty
    setup
  end

  def setup
    # Set up the display.
    # Function set with 8-bit data length, 2 lines, and 5x7 dot size.
    # Entry mode set; increment cursor direction; do not automatically shift.
    # Cursor/display shift; cursor move.
    # Display On; cursor off; do not blink.
    "\x38\x06\x10\x0c\x01".split().each do |byte|
      send_instruction(byte)
    end
  end

  def set_cursor(pos)
    unless pos.is_a? Array
      # Global pos (1 - 80)
      row = 1
      while pos > 20
        row += 1
        pos -= 20
      end
      pos = [row, pos]
    end
    # As an array of [row (1 - 4), column (1 - 20)]
    send_bytes "\xfe" + (0b10000000 + ROW_OFFSETS[pos[0]-1] + pos[1]-1).chr
  end

  def send_bytes(str, delay=WRITE_DELAY)
    # Send a stream of bytes to the Pertelian.
    # Also, sleep for delay seconds between sending each byte.
    str.split('').each do |byte|
      @sp.write byte
      sleep delay
    end
  end

  def send_instruction(byte)
    # Send an instruction byte to the Pertelian.
    send_bytes ["\xfe", byte].to_s, INSTRUCTION_DELAY
  end

  def power(on)
    # Turn the power on or off.
    on ? send_instruction("\x0c") : send_instruction("\x08")
  end

  def backlight(on)
    # Turn the backlight on or off.
    on ? send_instruction("\x03") : send_instruction("\x02")
  end

  def clear
    # Clear the display.
    send_instruction("\x01")
  end

  def message(msg)
    # Display a message.
    send_bytes(msg)
  end

  def set_custom_character
    #TODO
  end
end

