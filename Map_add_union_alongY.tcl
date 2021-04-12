set prefixes $argv
set InMap1 [lindex $prefixes 0]
set InMap2 [lindex $prefixes 1]
set OutMap [lindex $prefixes 2]

voltool trim -amt {0 0 0 2 0 0} -i $InMap1 -o $InMap1.temp_trim.dx
voltool add -i1 $InMap1.temp_trim.dx -i2 $InMap2 -union -nointerp -o $OutMap
