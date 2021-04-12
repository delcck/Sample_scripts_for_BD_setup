#! /bin/bash -x

## stop on errors
set -e

##Task: Align solute (C2) and output charge configuration
prefixesC="cytC_pro"
#Define path
inPath="/Scr/delcck/Megacomplex/Jacob/Structure/cytC/"
seltext="all"

scriptPath="/Scr/delcck/Megacomplex/Jacob/"
scriptName="Align_C.tcl"

outPath="/Scr/delcck/Megacomplex/Jacob/Structure/cytC/"

shopt -s expand_aliases
alias vmdd='vmd -dispdev text'

for prefixC in $prefixesC; do
  inPro="$prefixC"
  inStr="$inPath$inPro"
  outPro="$prefixC"
  outStr="$outPath$outPro"
  vmdd -args $inStr $seltext $outStr < "$scriptPath$scriptName"
done
