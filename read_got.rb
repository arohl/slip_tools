#!/opt/local/bin/ruby -w

require "matrix.rb"

class Atom
	def initialize(name, coord)
		@name   = name
		@coord = coord
	end
	
	attr_reader :name, :coord
	
	def to_s
		"Atom: #{@name} - #{@coord}"
	end
end


#open GULP output file
got_filename = ARGV.pop
got_file = File.new(got_filename, "r")

# Hash to store frames
got_frames = Array.new

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
    got_line = got_file.gets
    while !got_line.include? "-----"
      tokens = got_line.split
      coord = Vector[tokens[3].to_f, tokens[4].to_f, tokens[5].to_f]
      frame.push Atom.new(tokens[1], coord)
      got_line = got_file.gets
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

