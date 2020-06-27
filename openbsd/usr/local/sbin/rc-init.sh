#!/bin/sh

atactl /dev/sd0c acousticdisable
atactl /dev/sd0c apmdisable
atactl /dev/sd0c readaheadenable
atactl /dev/sd0c smartenable

mixerctl outputs.line=231,231
mixerctl outputs.master=255,255
