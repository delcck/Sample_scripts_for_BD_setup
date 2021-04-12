#! /usr/bin/env python

from __future__ import absolute_import, print_function
from os.path import isfile, getmtime
from gridData import Grid
import numpy as np
import sys

## Arguments
if len(sys.argv) != 4:
    raise(Exception('''Wrong number of arguments!
Usage: {} infile outfile netcharge'''.format(sys.argv[0])))


infile,outfile = sys.argv[1:3]
netCharge = float(sys.argv[3])
resolution = 2


## Subroutines
def info(*obj):
    print('INFO:',*obj , file=sys.stderr)

def loadGrid(file, **kwargs):
    data = Grid(file)
    return data

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
g.grid = g.grid * resolution**3

## Apply upper and lower bounds
ids = np.where( np.abs(g.grid[:]) > 0.01 )

numPoints = np.size(ids)
info(np.sum(g.grid), numPoints, np.sum(g.grid)/numPoints)

## Remove excess charge (in loop due to machine error)
while np.abs(np.sum(g.grid) - netCharge) > 0.0001:
    g.grid[ids] = g.grid[ids] + (netCharge-np.sum(g.grid))/numPoints
    info(np.sum(g.grid), numPoints, np.sum(g.grid)/numPoints)

info("Final charge", np.sum(g.grid))

## Write output
g.export( outfile )
