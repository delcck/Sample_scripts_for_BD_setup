########################################
## Write out potentials ##
########################################

## Parsing the input arguments

set prefixes $argv

set potResolution 0.5   ;#potential resolution
set IDs ""

set ClusterFile [lindex $prefixes 0]
set vdwType [lindex $prefixes 1]
set systemParameterDir [lindex $prefixes 2]
set psfName [lindex $prefixes 3]
set InDir [lindex $prefixes 4]
set OutDir [lindex $prefixes 5]
set tempT [lindex $prefixes 6]


#Construct the list of diffusing particles
set preNum [llength $prefixes]
set prefixesP ""
for {set i 7} {$i < $preNum} {incr i} {
        lappend prefixesP [lindex $prefixes $i]
}
puts $prefixesP

## import clustering results for $vdwType
set FtempName $ClusterFile

set ch [open $FtempName r]
set i 0
while {[expr ![eof $ch]]} {
        gets $ch inputData($i)
        puts $inputData($i)
        incr i
}
close $ch

set DataNum [expr $i - 1]

set newR [lindex $inputData($vdwType) 0]
set newE [lindex $inputData($vdwType) 1]


## Load parameters into ILS (ILS = implicit ligand sampling) <- Read that on VMD user guide
## And prepare calculations

package require ilstools
ILStools::readcharmmparams [glob $systemParameterDir*]

foreach prefix $prefixesP {
  set molN $prefix
  mol new $psfName.psf
  mol addfile $InDir$molN.pdb
  set al [atomselect top "all"]
  set minmax [measure minmax $al]
  lassign $minmax min max
  set max [vecadd $max {0 0 12}]
  set minmaxPot "{$min} {$max}"


  ILStools::assigncharmmparams top; # sets radius and occupancy to
                                      # rmin and eps
                                      #set ScaleList "1 0.8 0.6 0.4 0.2 0.1"
  set ScaleList 1

                                      ## loop over new LJ params
                                      ## the epsilon of each LJ params is modified by the list of scaling parameters
  foreach scaling $ScaleList {
    set eMod [expr $newE*$scaling]
    ## write potential grid
    volmap ils top $minmaxPot -cutoff 12.0 -o $OutDir$molN.vdw$vdwType.pot_$scaling.dx -res $potResolution -subres 3 -probecoor {{0.01 0.01 0.01}} -probevdw "{$eMod $newR}" -maxenergy 20 -orient 1 -first 0 -last 0
    }
    mol delete top
}
