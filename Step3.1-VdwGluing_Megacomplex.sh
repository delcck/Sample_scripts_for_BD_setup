#! /bin/bash -x

## stop on errors
set -e

##Task: Glue the vdw potential fragments togetehr

xBeg=0
xEnd=3
yBeg=0
yEnd=3
ScaleF="1"
xDeltaL="0 1 2 3"
yDeltaL="0 1 2 3"
VdwType="0 1 2 3"
memType="PC CL"
qcr6Type="2QCR6 0QCR6"
btwName="_"
DirSuffix="Mega"
vdwSuffix="_Delta"
strDir="/Scr/delcck/Megacomplex/Jacob/Structure"
mapDir="/Scr/delcck/Megacomplex/Jacob/Maps"
Temp=310  #for mitochondria
scriptDir="/Scr/delcck/Megacomplex/Jacob/"
scriptNameX="Map_add_union_alongX.tcl"
scriptNameY="Map_add_union_alongY.tcl"


export PATH=/Scr/cmaffeo2/anaconda3/bin:$PATH
## aliases
shopt -s expand_aliases
alias vmdd='vmd -dispdev text'

################################
## Gluging:

for memName in $memType; do
  for qcrName in $qcr6Type; do
    sysName="$memName$DirSuffix"
    DirStr="$strDir/$sysName/"
    DirMap="$mapDir/$sysName/"
    psfDir="$strDir/$sysName/"
    prefixMega="Mega_$qcrName$vdwSuffix"
    for vdwT in $VdwType; do
      #First glue along X  from left to right for each Y
      for yD in  $yDeltaL; do
        xtemp=$xBeg
        xtempNext=$((xtemp + 1))
        InName1="$DirMap$prefixMega.$xtemp.$yD.vdw$vdwT.pot_$ScaleF.dx"
        InName2="$DirMap$prefixMega.$xtempNext.$yD.vdw$vdwT.pot_$ScaleF.dx"
        OutTemp="$DirMap$prefixMega.$xtempNext.$yD.vdw$vdwT.partial_add.dx"
        vmdd -args $InName1 $InName2 $OutTemp < $scriptDir$scriptNameX
        xtemp=$xtempNext
        while (( $(echo "$xtemp < $xEnd") )); do
          xtempNext=$((xtemp + 1))
          InName1="$DirMap$prefixMega.$xtemp.$yD.vdw$vdwT.partial_add.dx"
          InName2="$DirMap$prefixMega.$xtempNext.$yD.vdw$vdwT.pot_$ScaleF.dx"
          OutTemp="$DirMap$prefixMega.$xtempNext.$yD.vdw$vdwT.partial_add.dx"
          vmdd -args $InName1 $InName2 $OutTemp < $scriptDir$scriptNameX
          xtemp=$xtempNext
        done
      done
      #First glue along Y from bottomw to top for each
      ytemp=$yBeg
      ytempNext=$((ytemp + 1))
      InName1="$DirMap$prefixMega.$xEnd.$ytemp.vdw$vdwT.partial_add.dx"
      InName2="$DirMap$prefixMega.$xEnd.$ytempNext.vdw$vdwT.partial_add.dx"
      OutTemp="$DirMap$prefixMega.$xEnd.$ytempNext.vdw$vdwT.partial_addY.dx"
      vmdd -args $InName1 $InName2 $OutTemp < $scriptDir$scriptNameY
      ytemp=$ytempNext
      while (( $(echo "$ytemp < $yEnd") )); do
        ytempNext=$((ytemp + 1))
        InName1="$DirMap$prefixMega.$xEnd.$ytemp.vdw$vdwT.partial_addY.dx"
        InName2="$DirMap$prefixMega.$xEnd.$ytempNext.vdw$vdwT.partial_add.dx"
        OutTemp="$DirMap$prefixMega.$xEnd.$ytempNext.vdw$vdwT.partial_addY.dx"
        vmdd -args $InName1 $InName2 $OutTemp < $scriptDir$scriptNameY
        ytemp=$ytempNext
      done
      mv "$DirMap$prefixMega.$xEnd.$yEnd.vdw$vdwT.partial_addY.dx" "$DirMap$prefixMega.vdw$vdwT.tot.dx"
    done
  done
done
