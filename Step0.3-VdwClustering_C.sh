#! /bin/bash -x

## stop on errors
set -e

##Task: cluster charm-parameters for cytochrome c
prefixesC="cytC_pro"
parametersDir="/Scr/delcck/cytc-ARBD/parameters/C2/"
mapDir="/Scr/delcck/Megacomplex/Jacob/Maps/cytC/"
strDir="/Scr/delcck/Megacomplex/Jacob/Structure/cytC/"
scriptDir="/Scr/delcck/Megacomplex/Jacob/"
scriptName1="VdwClustering_noh_C.tcl"
scriptName2="VdwClustering_H_only_C.tcl"

export PATH=/Scr/cmaffeo2/anaconda3/bin:$PATH
## aliases
shopt -s expand_aliases
alias vmdd='vmd -dispdev text'


for prefixC in $prefixesC; do
  InName="$strDir$prefixC.aligned"
  outName1="$prefixC.vdw-assignments"
  outName2="$prefixC.hydrogen.vdw-assignments"
  vmdd -args $mapDir $outName1 $parametersDir $InName  < "$scriptDir$scriptName1"
  vmdd -args $mapDir $outName2 $parametersDir $InName  < "$scriptDir$scriptName2"
  cat "$mapDir$outName2.results" >> "$mapDir$outName1.results"
done
