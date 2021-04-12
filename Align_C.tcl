#####################################################################
## Align so the principle axes of seltext are along Cartesian axes ##
#####################################################################

set prefixes $argv
set prefix [lindex $prefixes 0]
set seltext [lindex $prefixes 1]
set outprefix [lindex $prefixes 2]
set psf $prefix.psf
set pdb $prefix.pdb

## proc to check if rotation matrix is right-handed
proc rotationIsRightHanded {R {tol 0.01}} {
    set x [coordtrans $R {1 0 0}]
    set y [coordtrans $R {0 1 0}]
    set z [coordtrans $R {0 0 1}]

    set l [veclength [vecsub $z [veccross $x $y]]]
    return [expr {$l < $tol}]
}
################################################################
## Load coordinates and create atom selections of first frame ##
################################################################
set ID [mol new $psf]
mol addfile $pdb waitfor all

set sel [atomselect $ID "$seltext" frame 0]
set all [atomselect $ID all frame 0]


###########################################################
## Find and apply transformation to align principle axes ##
###########################################################

## Center system on $sel
$all moveby [vecinvert [measure center $sel weight mass]]
## Get current moment of inertia to determine rotation to align
lassign [measure inertia $sel moments] com inertia moments

## Convert 3x3 rotation to 4x4 vmd transformation
set R [trans_from_rotate $inertia]

## Fix left-handed principle axes sometimes returned by 'measure inertia'
if { ! [rotationIsRightHanded $R] } {
    # puts "rotation $R is not right handed! Fixing!"
    set R [transmult {{1 0 0 0} {0 1 0 0} {0 0 -1 0} {0 0 0 1}} $R]
}

## Apply rotation and check that it worked
$sel move $R
lassign [measure inertia $sel moments] com inertia moments
foreach x0 {{1 0 0} {0 1 0} {0 0 1}} {
    set x [coordtrans [trans_from_rotate $inertia] $x0]
    if {[veclength [vecsub $x $x0]] > 0.01} {
        puts stderr "Failed sanity check:
   After transformation, moments of inertia are not aligned to xyz; probably the script was developed for a special case that worked"
        exit
    }
}


######################
## Write things out ##
######################

## Write transformation matrix to return histone to original conformation
set ch [open $outprefix.rotate-back.txt w]
foreach line [trans_to_rotate [transtranspose $R]] {
    puts $ch $line
}
close $ch

## Write out moments of inertia
set ms ""
foreach m $moments { lappend ms [veclength $m] }
set ch [open $outprefix.inertia.txt w]
puts $ch $ms
close $ch

## Write out mass
set ch [open $outprefix.mass.txt w]
puts $ch [measure sumweights $sel weight mass]
close $ch

## Write out psf, pdb and pqr (for apbs) of transformed selection
$sel writepdb $outprefix.aligned.pdb
$sel writepsf $outprefix.aligned.psf
$sel writepqr $outprefix.aligned.pqr
