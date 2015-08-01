#!/usr/bin/ruby -w

n_mols = ARGV.pop.to_f

line_no = 0
last_energy = -1000.0
while (line = gets)
  tokens = line.split
  e = tokens[3].to_f
  e = e * 96.484602794
  if (line_no == 0)
    ref = e
  end
  energy = e - ref
  delta_e = energy - last_energy 
  if delta_e < 0
    strain = last_energy/n_mols
    translation = (line_no - 1)*0.02
  	puts "%4.2f %4.2f" % [translation, strain]
	 	break
  end
  last_energy = energy
  line_no += 1
end
