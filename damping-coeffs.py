#! /usr/bin/env python2
# /software/python3-3.4.1/bin/python3 
#! /usr/bin/env python3

from __future__ import print_function

import numpy as np
import sys
def info(obj):
    print('INFO: ',obj , file=sys.stderr)


hydroproFile = sys.argv[1]
massFile = sys.argv[2]
inertiaFile = sys.argv[3]

lineNum = 1
with open(hydroproFile) as f:
    ## skip 49 lines
#    for line in f:
#        lineNum = lineNum + 1
#        if lineNum > 48: break
    while lineNum <= 48:
         f.readline()
         lineNum = lineNum + 1

    ## read 3 lines
    Dx = float( f.readline().split()[0] )
    Dy = float( f.readline().split()[1] )
    Dz = float( f.readline().split()[2] )

    ## skip two lines
    f.readline()
    f.readline()

    ## read 3 lines
    Rx = float( f.readline().split()[3] )
    Ry = float( f.readline().split()[4] )
    Rz = float( f.readline().split()[5] )

with open(massFile) as f:
    mass = float( f.readline() )
with open(inertiaFile) as f:
    inertia = [float(x) for x in f.readline().split()]

## convert
# units "(295 k K) / (( cm^2/s) *  amu)" "1/ns"
Dx,Dy,Dz = [ 24.527692/(x*mass) for x in [Dx,Dy,Dz] ]
print(Dx,Dy,Dz)

# units "(295 k K) / ((1 /s) *  amu AA^2)" "1/ns"
Rx,Ry,Rz = [ 2.4527692e+17 / (x*mass) for x,mass in zip([Rx,Ry,Rz],inertia)]
print(Rx,Ry,Rz)

