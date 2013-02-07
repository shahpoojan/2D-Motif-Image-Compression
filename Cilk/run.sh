#!/bin/tcsh
#PBS -q class
#PBS -l nodes=1:sixcore
#PBS -l walltime=01:00:00
#PBS -N Poojan

cd Cilk
echo "Cilk Implementation"
time ./main 128 1 0
