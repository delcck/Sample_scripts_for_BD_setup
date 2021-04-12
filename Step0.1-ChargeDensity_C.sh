#! /bin/bash -x

## stop on errors
set -e

##Task: compute the charge density of C2, which is independent of the ion concentration

## variables
prefixesC="cytC_pro"
DirStr="/Scr/delcck/Megacomplex/Jacob/Structure/cytC/"
DirMap="/Scr/delcck/Megacomplex/Jacob/Maps/cytC/"
scriptDir="/Scr/delcck/Megacomplex/Jacob/"
tempScript="ChargeDensity_Solute.tcl"
pythonPath="/Scr/cmaffeo2/anaconda3/bin/python"
pythonScript="fix-charge.py"
pythonDir="/Scr/delcck/Megacomplex/Jacob/"


export PATH=/Scr/cmaffeo2/anaconda3/bin:$PATH
## aliases
shopt -s expand_aliases
alias vmdd='vmd -dispdev text'

################################
## Charge distribution of solute ##
################################
for prefixC in $prefixesC; do
  InName="$DirStr$prefixC.aligned"
  OutName="$DirMap$prefixC.aligned"
  TempName="$DirMap$prefixC.temp"
  vmdd -args $InName $TempName < "$scriptDir$tempScript"
  sed -r 's/^([0-9]+)e/\1.0e/g; s/ ([0-9]+)e/ \1.0e/' "$TempName.chargeDensity.dx" > "$TempName.chargeDensity_2.dx"
  sed -r 's/^(-[0-9]+)e/\1.0e/g; s/ (-[0-9]+)e/ \1.0e/' "$TempName.chargeDensity_2.dx" > "$TempName.chargeDensity_3.dx"
  #$pythonPath $pythonDir$pythonScript $TempName.chargeDensity_3.dx $OutName.charge.dx $(cat $TempName.netCharge.dat) &
  $pythonPath $pythonDir$pythonScript $TempName.chargeDensity_3.dx $OutName.charge.dx $(cat $TempName.netCharge.dat)
done
