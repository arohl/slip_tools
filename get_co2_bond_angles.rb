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

def calc_angle(v1, v2)
  return Math.atan2((v1.cross(v2)).magnitude, v1.dot(v2))*180/Math::PI
end

#open xyz file
xyz_filename = ARGV.pop
xyz_file = File.new(xyz_filename, "r")

#open output file
angle_file = File.new("bond_angles.txt", "w")

# Hash to store frames
xyz_frames = Array.new

while xyz_line = xyz_file.gets

  # arrays to store atom coordinates
  frame = Array.new

  # read number of atoms
  natoms = xyz_line.to_i

  # skip comment line
  xyz_file.gets

  # read atoms
  1.upto(natoms) do
    xyz_line = xyz_file.gets
    tokens = xyz_line.split
    coord = Vector[tokens[1].to_f, tokens[2].to_f, tokens[3].to_f]
    frame.push Atom.new(tokens[0], coord)
  end
  xyz_frames.push frame
end

# calculate the region 1 molecule vectors from the first frame

frame = xyz_frames[0]

# number of molecules want angles for - there are 4 rows (i.e. 8 mols) in region 2 and 3
n_mols = natoms/3 - 8

angle_orig = Array.new

# calculate the region 1 molecule spherical angles from the first frame
frame = xyz_frames[0]

# loop over each molecule
for i in 0..n_mols-1 do
  vec1 = frame[i*3].coord - frame[i*3+1].coord
  vec2 = frame[i*3+2].coord - frame[i*3+1].coord
  angle_orig[i] = calc_angle(vec1, vec2)
  puts angle_orig[i]
end
# loop over all frames calculating change in bond angles
xyz_frames.each do|f|
  # region 1 atoms are the first atoms in each frame
  for i in 0..n_mols-1 do
    vec1 = f[i*3].coord - f[i*3+1].coord
    vec2 = f[i*3+2].coord - f[i*3+1].coord
    angle = calc_angle(vec1, vec2)
    angle_file.print "%8.2f " % [angle - angle_orig[i]]
  end
  angle_file.print "\n"
end
