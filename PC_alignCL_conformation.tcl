set prefixes $argv
set qcrName [lindex $prefixes 0]
set strDir [lindex $prefixes 1]
set orientateSuffix [lindex $prefixes 2]


##1st load the corresponding CL structure
set CLpsf $strDir/CLMega/Mega_$qcrName.psf
set CLpdb $strDir/CLMega/Mega_$qcrName.pdb

mol load psf $CLpsf pdb $CLpdb
set CLid [molinfo top get id]

##2nd load the PC fitting structure
set PCpsf $strDir/PCMega/Mega_$qcrName.psf
set PCpdb $strDir/PCMega/Mega_$qcrName.pdb

mol load psf $PCpsf pdb $PCpdb
set PCid [molinfo top get id]

##set output
set PCoutpsf $strDir/Mega_$qcrName$orientateSuffix.psf
set PCoutpdb $strDir/Mega_$qcrName$orientateSuffix.pdb


##megacomplex fitting
set qcr6Type $qcrName
if {[string equal $qcr6Type "2QCR6"]} {
  set selTextPC "protein"
  set selTextCL "protein"
} elseif {[string equal $qcr6Type "0QCR6"]} {
  set selTextCL "name CA and segname PP13 PP36"
  set selTextPC "name CA and segname PP13 PP42"
}
set CLtar [atomselect $CLid "$selTextCL"]
set PCfit [atomselect $PCid "$selTextPC"]
set M [measure fit $PCfit $CLtar]
set PCal [atomselect $PCid "all"]
$PCal move $M

##fit membranes getting out of box
##measure minmax of CL model
set CLal [atomselect $CLid "all"]
set MinMax [measure minmax $CLal]
set xmin [lindex [lindex $MinMax 0] 0]
set xmax [lindex [lindex $MinMax 1] 0]
set ymin [lindex [lindex $MinMax 0] 1]
set ymax [lindex [lindex $MinMax 1] 1]
$PCal set beta 0
set PCmem [atomselect $PCid "chain  M"]
set zPCref [lindex [measure center $PCmem] 2]

##those below xmin
set selPC1 [atomselect $PCid "same residue as (x < $xmin)"]
$selPC1 set beta 1
set mv1 [measure center $selPC1]
$selPC1 moveby [vecscale -1 $mv1]
$selPC1 move [transaxis x 180]
$selPC1 move [transaxis z -20]
set tempMM [measure minmax $selPC1]
set tempXMin [lindex [lindex $tempMM 0] 0]
set tempYMax [lindex [lindex $tempMM 1] 1]
set mvx [expr $xmin - $tempXMin]
set mvy [expr $ymax - $tempYMax]
$selPC1 moveby "$mvx $mvy $zPCref"
#Fine tuning based on inspection
$selPC1 move [transaxis y 2]

##those beyond xmax
set selPC2 [atomselect $PCid "same residue as (x > $xmax)"]
$selPC2 set beta 2
set mv2 [measure center $selPC2]
$selPC2 moveby [vecscale -1 $mv2]
$selPC2 move [transaxis x 180]
$selPC2 move [transaxis z -20]
set tempMM [measure minmax $selPC2]
set tempXMax [lindex [lindex $tempMM 1] 0]
set tempYMin [lindex [lindex $tempMM 0] 1]
set mvx [expr $xmax - $tempXMax]
set mvy [expr $ymin - $tempYMin]
$selPC2 moveby "$mvx $mvy $zPCref"
$selPC2 move [transaxis y 2]

##those below ymin
set selPC3 [atomselect $PCid "same residue as (y < $ymin)"]
$selPC3 set beta 3
set mv3 [measure center $selPC3]
$selPC3 moveby [vecscale -1 $mv3]
$selPC3 move [transaxis y 180]
$selPC3 move [transaxis z -20]
set tempMM [measure minmax $selPC3]
set tempXMin [lindex [lindex $tempMM 0] 0]
set tempYMin [lindex [lindex $tempMM 0] 1]
set mvx [expr $xmin - $tempXMin]
set mvy [expr $ymin - $tempYMin]
$selPC3 moveby "$mvx $mvy $zPCref"
$selPC3 move [transaxis x 1]

##those beyond ymax
set selPC4 [atomselect $PCid "same residue as (y > $ymax)"]
$selPC4 set beta 4
set mv4 [measure center $selPC4]
$selPC4 moveby [vecscale -1 $mv4]
$selPC4 move [transaxis y 180]
$selPC4 move [transaxis z -20]
set tempMM [measure minmax $selPC4]
set tempXMax [lindex [lindex $tempMM 1] 0]
set tempYMax [lindex [lindex $tempMM 1] 1]
set mvx [expr $xmax - $tempXMax]
set mvy [expr $ymax - $tempYMax]
$selPC4 moveby "$mvx $mvy $zPCref"
$selPC4 move [transaxis x 1]

set PCout [atomselect top "all"]
$PCout writepsf $PCoutpsf
$PCout writepdb $PCoutpdb
