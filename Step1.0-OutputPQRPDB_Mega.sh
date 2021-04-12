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
memType="PC"
qcr6Type="2QCR6"
btwName="_"
DirSuffix="Mega"
scriptDir="/Scr/delcck/Megacomplex/Jacob/"
scriptAlign="Output_align_reduce_megacomplex.tcl"
scriptPQR="PQR_output_megacomplex.tcl"
scriptPDBforILS="Megacomplex_dissect_for_ILS.tcl"
segmentSuffix="_Delta"
numPerSide=4
SlicingBuff=1
#For PC model
orientateScript="PC_fit_to-CL_auto.tcl"
strDir="/Scr/delcck/Megacomplex/Jacob/Structure"
orientateSuffix="_corrected"
#For both PC & CL model
relabelScript="relabelStructure_auto.tcl"
relabelSuffix="relabelled"


export PATH=/Scr/cmaffeo2/anaconda3/bin:$PATH
## aliases
shopt -s expand_aliases
alias vmdd='vmd -dispdev text'

################################
for memName in $memType; do
  for qcrName in $qcr6Type; do
    prefixMega="Mega_$qcrName"
    sysName="$memName$DirSuffix"
    psfDir="$strDir/$sysName/"
    pdbDir="$strDir/$sysName/"
    pqrDir="$strDir/$sysName/"
    outDir="$strDir/$sysName/"


    if [[ "$memName" = "PC" ]]; then
      vmdd -args $qcrName $strDir $orientateSuffix < "$scriptDir$orientateScript"
    fi

    vmdd -args $memName $qcrName $relabelSuffix $orientateSuffix $strDir < "$scriptDir$relabelScript"

    InpsfName="$psfDir$prefixMega.$relabelSuffix"
    InpdbName="$pdbDir$prefixMega.$relabelSuffix"
    OutName="$outDir$prefixMega.aligned"

    #Align structure & produce the part of structure that is needed for BD
    vmdd -args $InpsfName $InpdbName $OutName < "$scriptDir$scriptAlign"

    #Output pqr for re-constructed Megacomplex
    vmdd -args $OutName $OutName $OutName < "$scriptDir$scriptPQR"

    #Output pdb fragment for ILS
    segmanePrefix="$outDir$prefixMega$segmentSuffix"
    vmdd -args $OutName $OutName $segmanePrefix $numPerSide $SlicingBuff < "$scriptDir$scriptPDBforILS"
  done
done
