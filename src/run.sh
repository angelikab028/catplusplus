#!/bin/bash
filename="$1"

echo -e "running Makefile...\n"
make
usleep 10000
echo -e "\n"
usleep 10000
echo -e "running code generation...\n"
./catnip "$filename" > test.mil
usleep 10000
echo -e "\n"
usleep 10000
echo -e "running mil_run\n"
mil_run test.mil