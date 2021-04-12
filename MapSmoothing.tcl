set prefixes $argv
set InMap1 [lindex $prefixes 0]
set Width [lindex $prefixes 1]
set OutMap [lindex $prefixes 2]

voltool smooth -sigma $Width -i $InMap1 -o $OutMap
