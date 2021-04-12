set prefixes $argv
set inStr [lindex $prefixes 0]
set outStr [lindex $prefixes 1]

set resolution 2.0

set ID [mol new $inStr.psf]
mol addfile $inStr.pdb
set all [atomselect $ID all]

set netCharge [measure sumweights $all weight charge]

## Write out charge density
volmap density $all -o $outStr.chargeDensity.dx -res $resolution -weight charge

set ch [open $outStr.netCharge.dat w]
puts $ch $netCharge
close $ch
