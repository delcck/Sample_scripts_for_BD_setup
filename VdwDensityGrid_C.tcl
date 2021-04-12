########################################
## Write out densities and potentials ##
########################################

## Parsing the input arguments

set prefixes $argv

set potResolution 0.5   ;#potential resolution
set denResolution 2     ;#density resolution
set IDs ""

set OutDir [lindex $prefixes 0]
set OutFileName [lindex $prefixes 1]
set ParticleParameterDir [lindex $prefixes 2]
set InDir [lindex $prefixes 3]

#Construct the list of diffusing particles
set preNum [llength $prefixes]
set prefixesP ""
for {set i 4} {$i < $preNum} {incr i} {
        lappend prefixesP [lindex $prefixes $i]
}
puts $prefixesP

set minRadius 0.5

## import clustering results
set FtempName $OutDir$OutFileName.results

set ch [open $FtempName r]
set i 0
while {[expr ![eof $ch]]} {
        gets $ch inputData($i)
        puts $inputData($i)
        incr i
}
close $ch

set DataNum [expr $i - 1]

set newR ""
set newE ""
for {set i 0} {$i < $DataNum} {incr i} {
        set tempNum [llength $inputData($i)]
        set typeArray($i) ""
        lappend newR [lindex $inputData($i) 0]
        lappend newE [lindex $inputData($i) 1]
        for {set j 2} {$j < $tempNum} {incr j} {
                #set typeArray($i) [concat $typeArray($i) [lindex $inputData($i) $j]]
                lappend typeArray($i) [lindex $inputData($i) $j]
        }
}

set checkpointFile $OutDir$OutFileName.reference.dat

set ch [open $checkpointFile w]
set i 0
foreach r $newR e $newE {
    puts $ch "$r $e $typeArray($i)"
    incr i
}
close $ch

## Load parameters into ILS (ILS = implicit ligand sampling) <- Read that on VMD user guide
## And prepare calculations

package require ilstools
ILStools::readcharmmparams [glob $ParticleParameterDir/*]

foreach prefix $prefixesP {
  set molN $InDir$prefix
  set ID [mol new $molN.psf]
  mol addfile $molN.pdb
  lappend IDs $ID

  ILStools::assigncharmmparams $ID; # sets radius and occupancy to
                                      # rmin and eps
}
## Loop over molecules
foreach prefix $prefixesP ID $IDs {
    set all [atomselect $ID all]
    set minmax [measure minmax $all]

    lassign $minmax min max
    set min [vecsub $min {12 12 12}]
    set max [vecadd $max {12 12 12}]
    set minmaxPot "{$min} {$max}"

    #set ScaleList "1 0.8 0.6 0.4 0.2 0.1"
    set ScaleList 1

    ## loop over new LJ params
    ## the epsilon of each LJ params is modified by the list of scaling parameters

    set i 0
    foreach r $newR e $newE {
        foreach scaling $ScaleList {
                #set eMod [expr $e*$scaling]
                ## write out density grid
                set sel [atomselect $ID "type $typeArray($i)"]

                #volmap interp $all -o $outdirN/$prefix.vdw$i.den.dx -res $denResolution
                volmap interp $sel -o $OutDir$prefix.vdw$i.den.dx -res $denResolution
                #puts "$eMod $r [$sel num] $scaling $i"
                ## write potential grid
                #volmap ils $ID $minmaxPot -cutoff 12.0 -o $outdirN/$prefix.vdw$i.pot_$scaling.dx -res $potResolution -subres 3 -probecoor {{0.01 0.01 0.01}} -probevdw "{$eMod $r}" -maxenergy 20 -orient 1 -first 0 -last 0
                }

        incr i
        }
}
