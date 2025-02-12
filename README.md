# This repo holds the FIO test scripts.

Running these scripts enables replication of the testing described in the CoreWeave Storage IO performance Blog. Refer to the blog for more information.

http://www.coreweave.com/blog/storage-benchmarking-distributed-file-storage

The tests are designed to be run under Slurm.

## To run the tests.

Edit the Slurm settings in the top of the fio-tests.slurm file. Some directives in particular are worth setting for your environment.

This defines how many nodes will be used in the test.
```sh
#SBATCH --nodes=8
```

This defines how many tasks per node. Logically it makes sense to match the number of GPUs per node.
```sh
#SBATCH --ntasks-per-node=8
```

This ensures no other jobs will run on those same nodes whilst the test is ongoing.
```sh
#SBATCH --exclusive
```

This is the partition the tests will be sent to.
```sh
#SBATCH -p h200
```

A little further down the script, 2 paths are defined. MNTPATH defines a temporary location where the container image is stored. TMPPATH is the path that will be tested. Revise these to fit your environment.
```sh
MNTPATH=/mnt/perftest
TMPPATH=$MNTPATH/fiotests
```

Note the filesystem is not cleaned up after testing. So please manually remove the test folder when testing is complete.

Submit the job with the command
```sh
sbatch fio-tests.slurm
```

## To collect the results

When the test has finished, you can collect the results by running the python script. No special setup or libraries are needed.
```sh
python3 fio-results.py name-of-slurm-log
```
