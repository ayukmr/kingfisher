# output generator
class Output
  # create output
  def initialize
    @location = 0
    @output = ''
    @loop_mems = []
  end

  # convert to code
  def to_s
    @output
  end

  # increment location
  def increment(location)
    cursor(location)
    @output << '+'
  end

  # decrement location
  def decrement(location)
    cursor(location)
    @output << '-'
  end

  # input to location
  def input(location)
    cursor(location)
    @output << ','
  end

  # output location
  def output(location)
    cursor(location)
    @output << '.'
  end

  # reset location
  def reset(location)
    cursor(location)
    @output << '[-]'
  end

  # set location
  def set(dest, source)
    reset(dest)
    @output << ('+' * source)
  end

  # loop block
  def loop_(&block)
    @output << '['
    block.call
    @output << ']'
  end

  # loop with location
  def loop_cursor(location, &)
    cursor(location)
    loop_(&)
  end

  # loop from input
  def loop_start(location)
    @loop_mems << (TEMP_MEM + 10 + @loop_mems.length)

    copy(location, @loop_mems.last)
    cursor(@loop_mems.last)

    @output << '['
  end

  # end loop from input
  def loop_end
    decrement(@loop_mems.pop)
    @output << ']'
  end

  # move location
  def cursor(location)
    if location < @location
      @output << ('<' * (@location - location))
    elsif location > @location
      @output << ('>' * (location - @location))
    end

    @location = location
  end

  # move source to dest
  def move(source, dest)
    loop_cursor(source) do
      increment(dest)
      decrement(source)
    end
  end

  # add source to dest
  def add(dest, source)
    loop_cursor(source) do
      increment(dest)
      increment(TEMP_MEM)

      decrement(source)
    end

    move(TEMP_MEM, source)
  end

  # subtract dest by source
  def subtract(dest, source)
    loop_cursor(source) do
      decrement(dest)

      increment(TEMP_MEM)
      decrement(source)
    end

    move(TEMP_MEM, source)
  end

  # copy source to dest
  def copy(source, dest)
    reset(dest)

    loop_cursor(source) do
      increment(dest)
      increment(TEMP_MEM)

      decrement(source)
    end

    move(TEMP_MEM, source)
  end

  # multiply dest by source
  def multiply(dest, source)
    loop_cursor(dest) do
      add(TEMP_MEM + 1, source)
      decrement(dest)
    end

    move(TEMP_MEM + 1, dest)
  end

  # divide dest by source
  def divide(dest, source)
    loop_cursor(dest) do
      increment(TEMP_MEM + 1)
      subtract(dest, source)
      cursor(dest)
    end

    move(TEMP_MEM + 1, dest)
  end
end

TEMP_MEM = 500

lines  = File.read(ARGV[0]).lines.map(&:strip)
output = Output.new

lines.each do |line|
  next if line.empty?

  # get commands
  command, args = line.match(/ *(\w+)( \w+( \w+)*)? */).captures
  args = args[1..].split.map(&:to_i) if args

  # process commands
  case command
  when 'inc'
    output.increment(args[0])

  when 'dec'
    output.decrement(args[0])

  when 'inp'
    output.input(args[0])

  when 'out'
    output.output(args[0])

  when 'rst'
    output.reset(args[0])

  when 'set'
    output.set(args[0], args[1])

  when 'rep'
    output.loop_start(args[0])

  when 'end'
    output.loop_end

  when 'add'
    output.add(args[0], args[1])

  when 'sub'
    output.subtract(args[0], args[1])

  when 'cpy'
    output.copy(args[0], args[1])

  when 'mul'
    output.multiply(args[0], args[1])

  when 'div'
    output.divide(args[0], args[1])

  else
    raise "invalid command `#{command}`"
  end
end

# return output
puts output
