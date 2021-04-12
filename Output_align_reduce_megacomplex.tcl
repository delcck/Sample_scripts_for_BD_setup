set prefixes $argv
set Inpsf [lindex $prefixes 0]
set Inpdb [lindex $prefixes 1]
set outName [lindex $prefixes 2]

mol new $Inpsf.psf
mol addfile $Inpdb.pdb

set al [atomselect top "all"]
#$al move [transaxis x 180]

#Use beta to select output regions - the following code is not going to work if there is any
# curvature in the membrane, which will  surely happen after MD on CL model
#$al set beta 0
#set selMem [atomselect top "segname MEMB and within 20 of (name P  and z > 0)"]
#$selMem set beta 1
#set mM [measure minmax $selMem]
#set mRef [lindex [lindex $mM 0] 2]
#set vRef [list 0 0 $mRef]
#set mV [vecscale -1 $vRef]

#set selPro [atomselect top "not segname MEMB and z > $mRef"]
#$selPro set beta 1

#New alignment code - Dec 29 2020
#1st select the part for Output
$al set beta 0
set selMem [atomselect top "segname MEMB and within 20 of (name P  and z > 0)"]
$selMem set beta 1
set mM [measure minmax $selMem]
set mRef [lindex [lindex $mM 0] 2]
set selPro [atomselect top "not segname MEMB and z > $mRef"]
$selPro set beta 1

#2nd align with the COM of the megacomplex, excluding qcr6, centered
set alignText "protein and name CA and not segname qcm1 qcm2"
set selAlign [atomselect top "$alignText"]
set mcom [measure center $selAlign]
set zRef [lindex $mcom 2]
set vRef [list 0 0 $zRef]
set mV [vecscale -1 $vRef]
$al moveby $mV

set selOut [atomselect top "beta 1"]
#$selOut update
$selOut writepsf $outName.psf
$selOut writepdb $outName.pdb
