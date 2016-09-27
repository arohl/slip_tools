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
    a = tokens[2].to_f
    alpha = tokens[5].to_f
    
    # read b
    got_line = got_file.gets
    tokens = got_line.split
    b = tokens[2].to_f
  end

  # FIXME - read as proper vector!
  if got_line.include? "Surface Cartesian vectors"
    # read surface vectors; start by skipping blank line
    got_file.gets
    
    # read a and alpha
    got_line = got_file.gets
    tokens = got_line.split
    x1 = tokens[0].to_f
    y1 = tokens[1].to_f
    
    # read b
    got_line = got_file.gets
    tokens = got_line.split
    x2 = tokens[0].to_f
    y2 = tokens[1].to_f
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
      tokens = got_line.split
      coord = Vector[tokens[3].to_f, tokens[4].to_f, tokens[5].to_f]
      start_frame.push SurfAtom.new(tokens[1], coord, tokens[6].to_f, region_no)
      n_atom = n_atom + 1
      got_line = got_file.gets
    end
  end
  
  got_line = got_file.gets
end

# need to calculate minimum z value and take its absolute value and add 10
# this will be the length of the c axis as per Damien's bash code
# FIXME this is pretty ugly!

min_z = 1000.0
start_frame.each do |at|
  if at.coord[2] < min_z
    min_z = at.coord[2]
  end
end
c = min_z.abs + 10.0

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

frame_no = 0
got_frames.each do |fr|
  atom_no = 1
  puts "MODEL %03d" % [frame_no]
  puts "CRYST1%9.3f%9.3f%9.3f%7.2f%7.2f%7.2f P1            0" % [a, b, c, 90.0, 90.0, alpha]
	fr.each do|f|
	  # region in PDB is "a" rather than 1 etc
	  region = ("A".ord - 1 + f.region).chr
	  x =  f.coord[0] * x1 + f.coord[1] * x2
	  y =  f.coord[0] * y1 + f.coord[1] * y2
 	  puts "ATOM  %5i%-4s%5s%2s%4i%4s%8.3f%8.3f%8.3f%6s%6s%10s%3s%8.4f" % [atom_no, " " + f.name, "UNK", region, "1", "", x, y, f.coord[2], "1.00", "0.00", "", f.name, f.charge]
 	  atom_no = atom_no + 1
  end
  puts "ENDMDL "
  frame_no = frame_no + 1
end

