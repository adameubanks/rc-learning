#!/bin/bash
#SBATCH -N 1
#SBATCH --ntasks-per-node=8
#SBATCH --account=your_allocation
#SBATCH -p instructional
#SBATCH -t 10:00:00

echo Running on `hostname`

#Load the versions of gcc, MPI, and Python/Anaconda in which you installed mpi4py
module load anaconda
module load gcc
module load openmpi

#Activate your environment. Edit to specify whatever name you chose.
conda activate mpienv

srun python MonteCarloPiMPI.py 100000000
