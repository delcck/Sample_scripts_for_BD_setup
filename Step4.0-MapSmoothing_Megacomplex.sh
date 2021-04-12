#! /bin/bash -x

## stop on errors
set -e

##Task: Smooth all potential maps as a manner to sample head group + side chain fluctuations
concL="0.02 .15 .40"
VdwType="0 1 2 3"
prefixesEM="mega_c3c4.aligned"

prefixesVdw="mega_c3c4_Delta"
sysName="Megacomplex"
DirMap="/Scr/delcck/Megacomplex/Jacob/Maps/$sysName/"
scriptDir="/Scr/delcck/Megacomplex/Jacob/"
scriptName="MapSmoothing.tcl"
smoothWidth=1

export PATH=/Scr/cmaffeo2/anaconda3/bin:$PATH
## aliases
shopt -s expand_aliases
alias vmdd='vmd -dispdev text'

#Smooth EM map
for conc in $concL; do
  for prefixEM in $prefixesEM; do
    InName1="$DirMap$prefixEM.$conc.elec.die.dx"
    OutTemp="$DirMap/$prefixEM.$conc.elec.die.smooth.dx"
    vmdd -args $InName1 $smoothWidth $OutTemp < $scriptDir$scriptName
  done
done

#Smooth Vdw map
for vdwT in $VdwType; do
  for prefixVdw in $prefixesVdw; do
    InName1="$DirMap$prefixVdw.vdw$vdwT.tot.dx"
    OutTemp="$DirMap$prefixVdw.vdw$vdwT.smooth.dx"
    vmdd -args $InName1 $smoothWidth $OutTemp < $scriptDir$scriptName
  done
done
