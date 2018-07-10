#!/bin/bash

for i in $(seq -w 256); do
    color=${i##+(0)}
    tput setab $color
    echo -n " $i "
    [ "$(expr $i % 16 )" == "0" ] && tput sgr0 && echo ""
done
tput sgr0
#for i in $(seq -w 256); do
#    color=${i##+(0)}
#    tput setaf $color
#    echo -n " $i "
#    [ "$(expr $i % 16 )" == "0" ] && tput sgr0 && echo ""
#done
#tput sgr0
