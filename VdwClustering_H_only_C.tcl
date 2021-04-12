######################################################################
## Use Implicit Ligand Sampling (ILS) tool of volmap to find the    ##
## energy of a alpha carbon atom (set through probevdw) interacting ##
## with the molecule in $prefix                                     ##
######################################################################

set prefixes $argv

set potResolution 0.5   ;#potential resolution
set denResolution 2     ;#density resolution
set IDs ""

set minRadius 0.5

set OutDir [lindex $prefixes 0]
set OutFileName [lindex $prefixes 1]
set ParticleParameterDir [lindex $prefixes 2]

#Construct the list of diffusing particles
set preNum [llength $prefixes]
set prefixesP ""
for {set i 3} {$i < $preNum} {incr i} {
        lappend prefixesP [lindex $prefixes $i]
}
puts $prefixesP

#############################
## Find full LJ parameters ##
#############################

## Load parameters into ILS (ILS = implicit ligand sampling) <- Read that on VMD user guide
package require ilstools
ILStools::readcharmmparams [glob $ParticleParameterDir/*]

## Loop over particles and find all LJparms
set ljParms ""
foreach prefix $prefixesP {
    set molN $prefix
    mol new $molN.psf
    mol addfile $molN.pdb
    [atomselect top "hydrogen"] writepsf $molN.Htemp.psf
    [atomselect top "hydrogen"] writepdb $molN.Htemp.pdb
    mol delete top

    #set ID [mol new $molN.psf]
    #mol addfile $molN.pdb
    set ID [mol new $molN.Htemp.psf]
    mol addfile $molN.Htemp.pdb
    lappend IDs $ID

    set sel [atomselect $ID "type HB"]; # two types of HB in charmm36
    $sel set type HB1
    set sel [atomselect $ID "type S3 S4"];      # specific fix for C10xlipid
    $sel set type S
    set sel [atomselect $ID "type NR4 NR5"];    # specific fix for C10xlipid
    $sel set type NR2


    ILStools::assigncharmmparams $ID; # sets radius and occupancy to
                                      # rmin and eps

                                      # ## Fix radius and epsilon for nitrogen (N* entry failed to be read)
                                      # set sel [atomselect $ID "name \"N.*\" and occupancy 0"]
                                      # $sel set occupancy -0.17
                                      # $sel set radius 1.824
                                      # ## note that type HO still have eps,rmin = 0 in Cornell et al.


    set all [atomselect $ID all]
    append ljParms " [lsort -unique [$all get {radius occupancy}]]"
}

## Remove duplicates between VMD molecules
set ljParms [lsort -unique $ljParms]

## Write LJ parameters to a file for python cluster analysis
set FtempName $OutDir$OutFileName.dat
set ch [open $FtempName w]
foreach vals $ljParms {
    lassign $vals r e
    if {$r < $minRadius} {continue};    # skip all those with small radius

    set count 0
    set types ""
    foreach ID $IDs {
        set sel [atomselect $ID "radius $r and occupancy \"$e\""]
        incr count [$sel num]
        append types " [lsort -unique [$sel get type]]"
    }
    set types [lsort -unique $types]
    puts "radius epsilon count (types): $r $e $count ($types)"
    lappend ljTypes $types
    puts $ch "$r $e $count"
}
close $ch

#########################################
## Run python to cluster LJ parameters ##
#########################################
set tmpF tmp.py
set tmpFile $OutDir$tmpF
set ch [open $tmpFile w]
puts $ch {
import numpy as np
from scipy.cluster import vq

numClusters = 3
}
puts $ch "d = np.loadtxt('$FtempName')"
puts $ch {
## build new dataset with 'count' (d[:,2]) entries of each value
d2 = [np.outer( np.ones((1,int(d[i,2]))) , d[i,:2] ) for i in range(d.shape[0])]

d2 = np.vstack( d2 )
d2w = vq.whiten( d2 )              # normalize features

ind = 0;
scalebase = d2w[ind,:];
while np.any(scalebase == 0):
  ind = ind + 1
  scalebase = d2w[ind,:]

scale = d2[ind,:] / d2w[ind,:]

## perform cluster analysis
codeBook,dist = vq.kmeans(d2w , numClusters)
assignments, dists = vq.vq( vq.whiten(d[:,:2]), codeBook)

print( " ".join(["%d" % a for a in assignments]) )
print( " ".join(["%.3f" % (c[0]*scale[0]) for c in codeBook]) )
print( " ".join(["%.3f" % (c[1]*scale[1]) for c in codeBook]) )
}
close $ch

unset env(PYTHONHOME)
set ch [open "|/Scr/cmaffeo2/anaconda3/bin/python $tmpFile" r]
#set ch [open "|python $tmpFile" r]

gets $ch assignments; list
gets $ch newR; list
gets $ch newE; list

close $ch

########################################
## Write out clustering result        ##
########################################

## Find atom types that map to each LJ parameter cluster
for {set i 0} {$i < [llength $newR]} {incr i} {
    set typeArray($i) ""
}
foreach i $assignments t $ljTypes {
    append typeArray($i) " $t"
}

set FoutName $OutDir$OutFileName.results
set ch [open $FoutName w]
set i 0
foreach r $newR e $newE {
    puts $ch "$r $e $typeArray($i)"
    incr i
}
close $ch
