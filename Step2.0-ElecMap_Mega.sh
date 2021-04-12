#! /bin/bash -x

## stop on errors
set -e

##Warning: the part of writing an apbs template fitting every system is not yet automatized!
## Further work is needed; a follow-up script that automatize the judgement for template parameters will be created ater
# Task: compute MegaComplex elec. potential
## variables
concL="0.02 .15 .40"
memType="PC CL"
qcr6Type="2QCR6 0QCR6"
btwName="_"
DirSuffix="Mega"
strDir="/Scr/delcck/Megacomplex/Jacob/Structure"
mapDir="/Scr/delcck/Megacomplex/Jacob/Maps"
pythonDir="/Scr/delcck/Megacomplex/Jacob/"
pythonScript="boundGrid.py"
templateDir="/Scr/delcck/Megacomplex/Jacob/template/"
templateName="abps_Megacomplex.txt"
Temp=310


export PATH=/Scr/cmaffeo2/anaconda3/bin:$PATH
## aliases
shopt -s expand_aliases
alias vmdd='vmd -dispdev text'

################################
## Electrostatic interactions ##
################################
for memName in $memType; do
  for qcrName in $qcr6Type; do
    for conc in $concL; do

      sysName="$memName$DirSuffix"
      pqrDir="$strDir/$sysName/"
      mapDir="$mapDir/$sysName/"

      prefixMega="Mega_$qcrName.aligned"
      OutABPSName="$prefixMega.$conc.die.apbs"

      sed "s|XXX|$prefixMega|g; s/CONC/$conc/g; s/TEMP/$Temp/g" "$templateDir$templateName" > "$pqrDir$OutABPSName"
      ## Create electrostatic potential
      ## - run poisson-boltzmann solver to get electrostatic potential around a histone
      ## - note: this could be done with DNA
      ## - see http://www.poissonboltzmann.org/docs/apbs-overview/
      ## - the path for apbs should be changed whenever needed
      cd $pqrDir
        /Common/linux/bin/apbs "$OutABPSName"
      cd $pythonDir
      $pythonDir$pythonScript "$pqrDir$prefixMega.$conc.elec.tmp.dx" "$mapDir$prefixMega.$conc.elec.die.dx" -20 20
    done
  done
done
