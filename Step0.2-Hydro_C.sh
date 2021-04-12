#! /bin/bash -x

## stop on errors
set -e

##Task: Compute the diffusion coefficient and damping constants for the solute (C2), which has its longest principle axis aligned to +ve z axis

prefixesC="cytC_pro"
inDir="/Scr/delcck/Megacomplex/Jacob/Structure/cytC/"
outDir="/Scr/delcck/Megacomplex/Jacob/hydropro-results/"
tempDir="/Scr/delcck/Megacomplex/Jacob/template/"
tempScript="hydropro.dat"
scriptDir="/Scr/delcck/Megacomplex/Jacob"
hydroproDir="/Scr/delcck/Megacomplex/Jacob/"

export PATH=/Scr/cmaffeo2/anaconda3/bin:$PATH
## aliases
shopt -s expand_aliases
alias vmdd='vmd -dispdev text'


#############################
## Coordinates and damping ##
#############################

mkdir -p $outDir

for prefixC in $prefixesC; do
  hyName="$prefixC.aligned"
  Mname="$inDir$prefixC"
  StrName="$Mname.aligned"
  sed "s|XXX|$hyName|g; s|MASS|$(cat $Mname.mass.txt)|g;" "$tempDir$tempScript" > "$outDir$tempScript"
  (
          cd $outDir
          ln -b -s "$StrName.pdb" .
          $hydroproDir/hydropro10-lnx.exe
  )
  $scriptDir/damping-coeffs.py $outDir$hyName.hyd-res.txt $Mname.mass.txt $Mname.inertia.txt > $outDir$hyName.damping-coeffs.txt
done
