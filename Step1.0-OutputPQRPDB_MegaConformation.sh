#! /bin/bash -x

## stop on errors
set -e

##Task: 1) Re-orientate PC model megacomplex to that of the corresponding CL model
##Task: 2)Generate pqr, pdb, and psf, each in the fromats fit for potential computation
##Remark: in the case of output pqr, should use CL_2QCR6 protein position as a reference so as to get a fair comparison for
##megacomplex binding

## variables
##PQR for elec; PDB segment for ILS
#Target Structure
memType="PC CL"

btwName="_"
DirSuffix="Mega_conformation"
scriptDir="/Scr/delcck/Megacomplex/Jacob/"
scriptAlign="Output_alignConformation.tcl"
scriptPQR="PQR_output_megacomplex.tcl"
scriptPDBforILS="Megacomplex_dissect_for_ILS.tcl"
segmentSuffix="_Delta"
numPerSide=4
SlicingBuff=1
#For PC model
orientateScript="PCflip.tcl"
strDir="/Scr/delcck/Megacomplex/Jacob/Structure"
#For both PC & CL model
relabelScript="relabelStructure_conformation.tcl"
relabelSuffix="relabelled"


export PATH=/Scr/cmaffeo2/anaconda3/bin:$PATH
## aliases
shopt -s expand_aliases
alias vmdd='vmd -dispdev text'

################################
for memName in $memType; do

  if [[ "$memName" = "CL" ]]; then
    frameL="f0 f150 f220 f480"
    prefixM="CL"
  elif [[ "$memName" = "PC" ]]; then
    frameL="f0 f15 f50 f220"
    prefixM="PC"
  fi

  for frameN in $frameL; do
    prefixMega="$prefixM$frameN"
    sysName="$memName$DirSuffix"
    psfDir="$strDir/$sysName/"
    pdbDir="$strDir/$sysName/"
    pqrDir="$strDir/$sysName/"
    outDir="$strDir/$sysName/"

    #1st relabel structures
    vmdd -args $memName $frameN $relabelSuffix $sysName $strDir < "$scriptDir$relabelScript"

    #2nd flip PC system
    if [[ "$memName" = "PC" ]]; then
      vmdd -args $frameN $relabelSuffix $sysName $strDir < "$scriptDir$orientateScript"
    fi

    InpsfName="$psfDir$prefixMega.$relabelSuffix"
    InpdbName="$pdbDir$prefixMega.$relabelSuffix"
    OutName="$outDir$prefixMega.aligned"

    #Align structure & produce the part of structure that is needed for BD
    vmdd -args $InpsfName $InpdbName $OutName < "$scriptDir$scriptAlign"

    #Output pqr for re-constructed Megacomplex
    vmdd -args $OutName $OutName $OutName < "$scriptDir$scriptPQR"


    #Output pdb fragment for ILS
    segmentPrefix="$outDir$prefixMega$segmentSuffix"
    vmdd -args $OutName $OutName $segmentPrefix $numPerSide $SlicingBuff < "$scriptDir$scriptPDBforILS"

  done

done
