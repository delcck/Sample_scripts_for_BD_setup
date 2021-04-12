#! /bin/bash -x

## stop on errors
set -e

##Task: generate particle density grid for clustering results on the charm-parameters for cytochrome c
prefixesC="cytC_pro"
parametersDir="/Scr/delcck/cytc-ARBD/parameters/C2/"
mapDir="/Scr/delcck/Megacomplex/Jacob/Maps/cytC/"
strDir="/Scr/delcck/Megacomplex/Jacob/Structure/cytC/"
scriptDir="/Scr/delcck/Megacomplex/Jacob/"
scriptName="VdwDensityGrid_C.tcl"


export PATH=/Scr/cmaffeo2/anaconda3/bin:$PATH
## aliases
shopt -s expand_aliases
alias vmdd='vmd -dispdev text'


for prefixC in $prefixesC; do
  InName="$prefixC.aligned"
  assignmentName="$prefixC.vdw-assignments"
  vmdd -args $mapDir $assignmentName $parametersDir $strDir $InName  < "$scriptDir$scriptName"
done
