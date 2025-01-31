#!/bin/bash
###
#SBATCH --job-name=fio_test
#SBATCH --nodes=8
#SBATCH --ntasks-per-node=8
#SBATCH --time=120:00
#SBATCH --output="%x.%j.out"
#SBATCH --exclusive
#SBATCH -p h200

# Setup a mount, used to mount the filesystem being tested. The container image will also be saved here.
MNTPATH=/mnt/perftest

# Setup the location where the temporary files will be saved. 
# When setup to run with 8 processes per node (to match the GPU count) 
# You will see 160G created per node.
# This script doesn't cleanup these files.
TMPPATH=$MNTPATH/fiotests

# Log the assigned nodes
echo "Using nodes: $SLURM_JOB_NODELIST"
echo running on $SLURM_NNODES nodes

# Create test container
srun -n 1 --container-image=ubuntu:22.04 \
     --container-remap-root  \
     --container-mounts=$MNTPATH:$MNTPATH \
     --container-save=$MNTPATH/fio.sqsh \
     bash -c "apt-get -y  update; apt-get install -y fio"

srun -N $SLURM_NNODES --exclusive  --container-image=$MNTPATH/fio.sqsh \
  --container-remap-root  \
  --container-mounts=$MNTPATH:$MNTPATH \
  --chdir=$TMPPATH \
    echo Loading container

# Run tests
# This is a bit inefficient as we load the container fresh for every test. 
# But it does ensure all the tests stay in sync
for OP in read randread write
do
  for BS in 32M 16M 8M 4M 2M 1M 512k 256k 128k 64k 32k 16k 8k 4k 2k 1k
  do
  export BS=$BS
  export OP=$OP
  srun -N $SLURM_NNODES --exclusive  --container-image=$MNTPATH/fio.sqsh \
     --container-remap-root  \
     --container-mounts=$MNTPATH:$MNTPATH \
     --chdir=$TMPPATH \
     bash -c "mkdir -p $TMPPATH/\`hostname\`; cd $TMPPATH/\`hostname\`; pwd; fio --name=test  --direct=1 --rw=$OP --size=20G --bs=$BS --ioengine=sync --refill_buffers --randrepeat=0 --runtime=120 --numjobs=8 --eta-newline=1"
     echo  
  done
done

# Clean up the container
rm $MNTPATH/fio.sqsh 
