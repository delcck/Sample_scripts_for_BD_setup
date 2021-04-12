#! /usr/bin/env python2

from gridData import Grid
import numpy as np
from scipy import signal

ones = np.ones([2,2,2])
zeros = np.zeros([2,2,2])

opts = dict(delta=3000,origin=-1500*np.array((1,1,1)))
g = Grid(zeros,**opts)
g.export('null.dx')



def blur3Dgrid(g,blur):
    sideLen = 2*int(blur*3)+1
    gauss = signal.gaussian( sideLen, blur )
    i = np.arange( sideLen )
    i,j,k = np.meshgrid(i,i,i)
    kernel = gauss[i]*gauss[j]*gauss[k]
    kernel = kernel/kernel.sum()
    return signal.fftconvolve(g,kernel,mode='same')

    ## tune these parameters to set the boundary conditions
  wallPos = 80                    # angstroms
  wallPosZ = 240                  # angstroms
  dx = 1                          # angstroms
  blur = 5                        # sets softness of BC (angstroms)
  wellDepth = -1                  # kcal/mol

  ## set up grid
  wallRange = (-1.5*(wallPos+2*blur), 1.5*(wallPos+2*blur))
  wallRangeZ = (-1.5*(wallPosZ+2*blur), 1.5*(wallPosZ+2*blur))
  x = np.linspace( wallRange[0], wallRange[1], int( (wallRange[1]-wallRange[0])/dx ) + 1 )
  z = np.linspace( wallRangeZ[0], wallRangeZ[1], int( (wallRangeZ[1]-wallRangeZ[0])/dx ) + 1 )
  dx = np.mean(np.diff(x))        # adjust dx to real value, not target
  X,Y,Z = np.meshgrid(x,x,z)      # create meshgrid for making potential

  ## define the potential
  pot = np.zeros( np.shape(X) )
  ids = np.where( (abs(X) < wallPos) * (abs(Y) < wallPos) * (abs(Z) < wallPosZ) )
  pot[ids] = wellDepth

  ## blur the square well so it is soft
  pot = blur3Dgrid(pot, blur/dx)

## write the potential out
origin = [wallRange[0], wallRange[0], wallRangeZ[0]+240]
opts = dict(delta=dx,origin=origin)
g = Grid(pot,**opts)
g.export('bc.dx')
