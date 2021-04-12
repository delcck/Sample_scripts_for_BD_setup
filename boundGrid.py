#! /usr/bin/env python

from __future__ import absolute_import, print_function
from os.path import isfile, getmtime
from gridData import Grid
import numpy as np
import sys

## Arguments
if len(sys.argv) != 5:
    raise(Exception('''Wrong number of arguments!
Usage: {} infile outfile lowerBound upperBound'''.format(sys.argv[0])))

infile,outfile = sys.argv[1:3]
lowerBound,upperBound = [float(x) for x in sys.argv[3:]]
assert(lowerBound < upperBound)

## Subroutines
def info(*obj):
    print('INFO:',*obj , file=sys.stderr)

def loadGrid(file, **kwargs):
    return Grid(file)

    ## Load cached grid where possible (ONLY use this if pickles are trusted)
    datafile = '{}.pickle'.format(file)
    assert(isfile(file))

    ## Read cache or original file
    if isfile(datafile) and getmtime(datafile) > getmtime(file):
        info("Reading {}".format(datafile))
        data = Grid()
        data.load(datafile)
    else:
        info("Creating {}".format(datafile))
        data = Grid(file)
        data.save(datafile)
    return data

## Load Data
g = loadGrid( infile )

## Apply upper and lower bounds
# ids = np.where(g.grid > upperBound)[0]
ids = np.where(g.grid > upperBound)
g.grid[ids] = upperBound
ids = np.where(g.grid < lowerBound)
g.grid[ids] = lowerBound

## Write output
g.export( outfile )
