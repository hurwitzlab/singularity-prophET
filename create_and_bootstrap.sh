#!/bin/bash

set -x

echo "Hello! starting $(date)"

sudo rm -rf prophet.img
singularity create -s 2048 prophet.img
sudo singularity bootstrap prophet.img ubuntu.sh

echo "Goodbye! ending $(date)"
