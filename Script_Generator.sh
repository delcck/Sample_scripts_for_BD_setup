#! /bin/bash -x

## stop on errors
set -e
shopt -s expand_aliases
alias vmdd='vmd -dispdev text'
#---PC vdw-potential
TempName="Step3.0-VdwPotential_Megacomplex_temp.sh"
outName="Step3.0_Vdw_PC_"

xDeltaL="0 1 2 3"
yDeltaL="0 1 2 3"
VdwType="0 1 2 3"

for xD in $xDeltaL; do
  for yD in $xDeltaL; do
    for vdwT in $VdwType; do
      sed "s|TRAJX|$xD|g; s|TRAJY|$yD|g; s|TRAVDW|$vdwT|g;" "$TempName" >  "$outName.$xD.$yD.vdw$vdwT.sh"
    done
  done
done
