#! /bin/bash -x

## stop on errors
set -e

##Task: Compute the vdw potential for each atome type upon k-mean clustering

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
prefixesC="cytC_pro"
Temp=310  #for mitochondria

DirParameterC1="/Scr/delcck/cytc-ARBD/MD_Simulation/Equilibration/Summit_parameters/"
scriptDir="/Scr/delcck/Megacomplex/Jacob/"
scriptName="VdwPotential_Megacomplex.tcl"
clusterDir="/Scr/delcck/Megacomplex/Jacob/Maps/cytC/"


export PATH=/Scr/cmaffeo2/anaconda3/bin:$PATH
## aliases
shopt -s expand_aliases
alias vmdd='vmd -dispdev text'

################################
## van der Waals interactions ##
################################

## We can model vdW interactions using the LJ parameters and creating
## a density grid for each pair of epsilon and radius values, but this
## would be slow to simulate

## One solution is to cluster atoms into a few groups with similar
## epsilon and radius, and use the average value for the density

## For simplicity, we want to use the same epsilon and radius for all
## particles in the system (otherwise we need to generate potential
## grids for each pair of particles)

## Create vdW densities and potentials
##  CUDA is disabled due to error in volmap's CUDA ILS code
#VMDNOCUDA=1

for memName in $memType; do
  for qcrName in $qcr6Type; do
    sysName="$memName$DirSuffix"
    DirStr="$strDir/$sysName/"
    DirMap="$mapDir/$sysName/"
    psfDir="$strDir/$sysName/"
    prefixMega="Mega_$qcrName$vdwSuffix"
    for prefixC in  $prefixesC; do
      ClusterFile="$clusterDir$prefixC.vdw-assignments.reference.dat"
      for xD in $xDeltaL; do
        for yD in $yDeltaL; do
          psfName="$psfDir$prefixMega.$xD.$yD"
          StrInName="$prefixMega.$xD.$yD"
          for vdwT in $VdwType; do
            prefixes="$ClusterFile $vdwT $DirParameterC1 $psfName $DirStr $DirMap $Temp $StrInName"
            vmdd -args $prefixes < $scriptDir$scriptName
          done
        done
      done
    done
  done
done
