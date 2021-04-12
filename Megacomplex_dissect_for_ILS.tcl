#Dissect structure into 4x4 pieces on the x-y plane
set prefixes $argv
set Inpsf [lindex $prefixes 0]
set Inpdb [lindex $prefixes 1]
set outNamePrefix [lindex $prefixes 2]
set numPerSide [lindex $prefixes 3]
set buff [lindex $prefixes 4]

#Obtain Delta x & Delta y
mol new $Inpsf.psf
mol addfile $Inpdb.pdb

set al [atomselect top "all"]
set mM [measure minmax $al]
set dimAl [vecsub [lindex $mM 1] [lindex $mM 0]]
set minX [expr [lindex [lindex $mM 0] 0] - $buff]
set minY [expr [lindex [lindex $mM 0] 1] - $buff]
set deltaX [expr ([lindex $dimAl 0] + 2*$buff)/$numPerSide]
set deltaY [expr ([lindex $dimAl 1] + 2*$buff)/$numPerSide]

for {set i 0} {$i < $numPerSide} {incr i} {
  for {set j 0} {$j < $numPerSide} {incr j} {
    set outName $outNamePrefix.$i.$j
    set xLow [expr $minX + $i*$deltaX]
    set yLow [expr $minY + $j*$deltaY]
    set xUp [expr $minX + ($i+1)*$deltaX]
    set yUp [expr $minY + ($j+1)*$deltaY]
    set sel [atomselect top "(x > $xLow and x < $xUp) and (y > $yLow and y < $yUp)"]
    $sel writepsf $outName.psf
    $sel writepdb $outName.pdb
  }
}
