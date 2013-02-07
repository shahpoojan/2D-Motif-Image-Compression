#!/bin/tcsh
#PBS -q class
#PBS -l nodes=1:gpu
#PBS -l walltime=01:00:00
#PBS -N Poojan

#echo "CUDA Implamentation"

cd CUDA
echo "CUDA Implementation"
time ./main.o 64 1 1
