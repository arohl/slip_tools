#!/opt/local/bin/ruby -w

require "matrix.rb"

class SurfAtom
	def initialize(name, coord, charge, region)
		@name   = name
		@coord  = coord
		@charge = charge
		@region = region
	end
	
	attr_reader :name, :coord, :charge, :region
	
	def to_s
		"SurfAtom: #{@name} - #{@coord} - #{@charge} - #{@region}"
	end
end

#open GULP output file
got_filename = ARGV.pop
got_file = File.new(got_filename, "r")

# Hash to store frames
got_frames = Array.new

# Read important information from header
n_atom = 0
start_frame = Array.new
got_line = got_file.gets
while !got_line.include? "Output for configuration"
  
  if got_line.include? "Surface cell parameters"
    # read surface cell; start by skipping blank line
    got_file.gets
    
    # read a and alpha
    got_line = got_file.gets
    tokens = got_line.split
    a = tokens[2]
    alpha = tokens[5]
    
    # read b
    got_line = got_file.gets
    tokens = got_line.split
    b = tokens[2]
  end
 
  if got_line.include? "Region"
    # read atom data for a region; start by reading region number
    tokens = got_line.split
    region_no = tokens[1].to_i
    # skip blank line
    got_file.gets
    # read atom lines
    got_line = got_file.gets
    while !got_line.include? "-----"
      # replace asterix with space in atom lines
      got_line.gsub!('*', ' ')
      puts got_line
      tokens = got_line.split
      coord = Vector[tokens[3].to_f, tokens[4].to_f, tokens[5].to_f]
      start_frame.push SurfAtom.new(tokens[1], coord, tokens[6].to_f, region_no)
      n_atom = n_atom + 1
      got_line = got_file.gets
    end
  end
  
  got_line = got_file.gets
end

puts n_atom

while got_line = got_file.gets
	
	# skip unless final coordinates
  if got_line.include? "Final fractional/Cartesian coordinates of atoms"
	
    # arrays to store atom coordinates
    frame = Array.new

    # skip 5 lines
    1.upto(5) do
      got_file.gets
    end
    
    # read atoms
    for i in 0..(n_atom - 1)
      got_line = got_file.gets
      tokens = got_line.split
      coord = Vector[tokens[3].to_f, tokens[4].to_f, tokens[5].to_f]
      frame.push SurfAtom.new(tokens[1], coord, start_frame[i].charge, start_frame[i].region)
    end
    got_frames.push frame
  end
end

got_frames.each do|x|
  puts "new frame"
	x.each do|f|
		puts f
  end
end

