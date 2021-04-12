set prefixes $argv
set psfName [lindex $prefixes 0]
set pdbName [lindex $prefixes 1]
set pqrName [lindex $prefixes 2]

mol new $psfName.psf
mol addfile $pdbName.pdb

set seltext "(not (water or ions) and z > 0)"
set sel [atomselect top "$seltext"]

$sel writepqr $pqrName.pqr
