#!/bin/bash

df -ht nfs | egrep -v "Filesy|etc|home|stage|export" | awk '{if (NF==5){print "ls -ld",$5} if (NF==6){print "ls -ld",$6}}' | sh
