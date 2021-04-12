set prefixes $argv
set memName [lindex $prefixes 0]
set qcrName [lindex $prefixes 1]
set relabelSuffix [lindex $prefixes 2]
set orientateSuffix [lindex $prefixes 3]
set strDir [lindex $prefixes 4]

set strPrefix "Mega_$qcrName"

if {[string equal $memName "CL"]} {
  set strPath "$strDir/CLMega/"
  set outPath "$strDir/CLMega/"

  if {[string equal $strPrefix "Mega_2QCR6"]} {
    set c3m1 "segname PRAA PRAB PRAC PRAE PRAF PRAH PROX PROY PROZ PP32"
    #set c3m2 "segname PROA PROB PROC PROD PROE PROF PROG PROH PROI PROK" #bug
    set c3m2 "segname PROA PROB PROC PROD PROE PROF PROH PROI PROK"
    set c4m1 "segname PRAG PRAI PRAJ PRAK PRAL PRAM PRAN PRAO PRAP PRAQ PRAR PRAS"
    set c4m2 "segname PROJ PROL PROM PRON PROO PROP PROQ PROR PROS PROT PROU PROW"
    set qcm1 "segname PRAD"
    set qcm2 "segname PP1"
  } elseif {[string equal $strPrefix "Mega_0QCR6"]} {
    set c3m1 "segname PP26 PP27 PP28 PP29 PP30 PP32 PP33 PP25 PP36"
    set c3m2 "segname PP1 PP2 PP3 PP4 PP5 PP6 PP8 PP9 PP10 PP13"
    set c4m1 "segname PP34 PP40 PP41 PP42 PP43 PP44 PP45 PP46 PP47 PP37 PP38 PP39"
    set c4m2 "segname PP20 PP21 PP22 PP23 PP24 PP11 PP12 PP14 PP15 PP16 PP17 PP18 PP19"
    set qcm1 "segname PP31"
    set qcm2 "segname PP7"
  }  elseif {[string equal $strPrefix "Mega_0.5QCR6"]} {
    set c3m1 "segname PP26 PP27 PP28 PP29 PP30 PP32 PP33 PP25 PP36"
    #set c3m2 "segname PP1 PP2 PP3 PP4 PP5 PP6 PP7 PP8 PP9 PP10 PP13" PP7 is an extra - bug
    set c3m2 "segname PP1 PP2 PP3 PP4 PP5 PP6 PP8 PP9 PP10 PP13"
    set c4m1 "segname PP34 PP40 PP41 PP42 PP43 PP44 PP45 PP46 PP47 PP37 PP38 PP39"
    set c4m2 "segname PP20 PP21 PP22 PP23 PP24 PP11 PP12 PP14 PP15 PP16 PP17 PP18 PP19"
    set qcm1 "segname PP31"
    set qcm2 "segname PP48"
  } elseif {[string equal $strPrefix "Mega_1QCR6"]} {
    set c3m1 "segname PRAA PRAB PRAC PRAE PRAF PRAH PROX PROY PROZ PP32"
    set c3m2 "segname PROA PROB PROC PROD PROE PROF PROH PROI PROK"
    set c4m1 "segname PRAG PRAI PRAJ PRAK PRAL PRAM PRAN PRAO PRAP PRAQ PRAR PRAS"
    set c4m2 "segname PROJ PROL PROM PRON PROO PROP PROQ PROR PROS PROT PROU PROW"
    set qcm1 "segname PRAD"
    set qcm2 "segname PROG"
  }
  set outPrefix $strPrefix
  mol load psf $strPath$strPrefix.psf pdb $strPath$strPrefix.pdb
} elseif {[string equal $memName "PC"]} {
  set strPath "$strDir/PCMega/"
  set outPath "$strDir/PCMega/"
  if {[string equal $strPrefix "Mega_2QCR6"]} {
    set c3m1 "segname PRAA PRAB PRAC PRAE PRAF PRAH PROX PROY PROZ PP32"
    set c3m2 "segname PROA PROB PROC PROD PROE PROF PROG PROH PROI PROK"
    set c4m1 "segname PRAG PRAI PRAJ PRAK PRAL PRAM PRAN PRAO PRAP PRAQ PRAR PRAS"
    set c4m2 "segname PROJ PROL PROM PRON PROO PROP PROQ PROR PROS PROT PROU PROW"
    set qcm1 "segname PRAD"
    set qcm2 "segname XP1"
  } elseif {[string equal $strPrefix "Mega_0QCR6"]} {
    set c3m1 "segname PP32 PP33 PP34 PP37 PP38 PP42"
    set c3m2 "segname PP3 PP4 PP5 PP8 PP9 PP13"
    set c4m1 "segname PP39 PP40 PP43 PP44 PP47 PP48 PP49 PP50 PP52 PP53 PP54 PP56 PP57 PP58"
    set c4m2 "segname PP10 PP11 PP14 PP15 PP18 PP19 PP21 PP24 PP23 PP20 PP25 PP27 PP29 PP28"
    set qcm1 "segname PP36"
    set qcm2 "segname XP1"
  }  elseif {[string equal $strPrefix "Mega_0.5QCR6"]} {
    set c3m1 "segname PP26 PP27 PP28 PP31 PP32 PP35"
    set c3m2 "segname PP3 PP4 PP5 PP8 PP9 PP12"
    set c4m1 "segname PP33 PP36 PP37 PP38 PP39 PP41 PP42 PP44 PP45 PP46"
    set c4m2 "segname PP10 PP13 PP14 PP15 PP16 PP18 PP19 PP21 PP22 PP23"
    set qcm1 "segname PP30"
    set qcm2 "segname XP1"
  }
  set outPrefix $strPrefix
  mol load psf $strPath$strPrefix$orientateSuffix.psf pdb $strPath$strPrefix$orientateSuffix.pdb
}


[atomselect top "$c3m1"] set segname c3m1
[atomselect top "$c3m2"] set segname c3m2
[atomselect top "$c4m1"] set segname c4m1
[atomselect top "$c4m2"] set segname c4m2
[atomselect top "$qcm1"] set segname qcm1
[atomselect top "$qcm2"] set segname qcm2

set al [atomselect top "all"]
$al writepsf $outPath$outPrefix.$relabelSuffix.psf
$al writepdb $outPath$outPrefix.$relabelSuffix.pdb
