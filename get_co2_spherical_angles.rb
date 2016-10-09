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

def inclination(vec)
  return Math.acos(vec[2]/vec.magnitude)*180/Math::PI
end

def azimuth(vec)
  return Math.atan2(vec[0], vec[1])*180/Math::PI
end

#open xyz file
xyz_filename = ARGV.pop
xyz_file = File.new(xyz_filename, "r")

#open output files
incl_file = File.new("incl_angles.txt", "w")
az_file = File.new("az_angles.txt", "w")


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

mol_orig = Array.new
incl_orig = Array.new
az_orig = Array.new

# calculate the region 1 molecule spherical angles from the first frame
frame = xyz_frames[0]

# loop over each molecule
for i in 0..n_mols-1 do
  mol_orig[i] = frame[i*3].coord - frame[i*3+2].coord
  incl_orig[i] = inclination(mol_orig[i])
  az_orig[i] = azimuth(mol_orig[i])
  puts incl_orig[i], az_orig[i]
end
# loop over all frames calculating change in spherical angles
xyz_frames.each do|f|
  # region 1 atoms are the first atoms in each frame
  for i in 0..n_mols-1 do
    mol = f[i*3].coord - f[i*3+2].coord
    incl = inclination(mol)
    az = azimuth(mol)
    incl_file.print "%8.2f " % [incl - incl_orig[i]]
    az_file.print "%8.2f " % [az - az_orig[i]]
  end
  az_file.print "\n"
  incl_file.print "\n"
end
