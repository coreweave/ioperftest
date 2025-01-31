#!/usr/bin/env python3

# This script should be run when the fio-test.slurm script has finished.
# The script parses the slurm log and grabs all the results from it.
# The parsing is simplistic. In case of any problems, double check fio output hasn't changed.
# Run the script, followed by the name of the Slurm Log file
# In Slurm, all teh results are sent to the same log file.

import argparse

parser = argparse.ArgumentParser("Fio Benchmark number finding code")
parser.add_argument("filename", help="Enter the filename of the Slurm log.", type=str)
args = parser.parse_args()

filename=args.filename

with open(filename) as f:
    lines=f.readlines()

results=[]
tests=[]

# Analyse the Slurm log file.
# Find the number of machines being tested and the bandwidth results.
for i in lines:
    if ": bw" in i:
        results.append(i.strip().split()[1])
        #print("results: "+i.strip().split()[1])
    if "running on" in i:
        machines=int(i.split()[2])
        #print("machine: "+str(machines))
    if "test: (g=0)" in i:
        tests.append(i)
        #print("test"+i)

# Loop through the results.
# Inner loop is the number of machines running each test. These many values are averaged.
# The range is max number of tests, doesn't matter so long as it is more than was run.
for i in range(600):
    vals=0
    total=0
    for j in range(machines):
        try:
            vals+=1
            onevalue=results[i*machines+j]
            teststats=tests[i*machines+j]
            number = onevalue.split("=")[1].split("M")[0].split("G")[0].split("K")[0]
            bwvalue=float(number)
            if "GiB" in onevalue:
                bwvalue=bwvalue*1024
            if "KiB" in onevalue:
                bwvalue=bwvalue/1024
            total=total+bwvalue
        except:
            pass
    avg=total/vals
    if total > 0:
        print("Total: " + format(total, '.2f')+" "+teststats.split()[2].split("=")[1][:-1]+" "+teststats.split()[6].split("-")[0])


    
   
    



