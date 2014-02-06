#!/bin/bash

#http://www.cdec-decoder.org/guide/tutorial.html

DATA_DIR=./cdec-spanish-demo

wget -O - http://data.cdec-decoder.org/cdec-spanish-demo.tar.gz |tar xz 
find . -name '._*' -delete 


# more monolingual English data from http://www.statmt.org/wmt14/translation-task.html
#mkdir -p $DATA_DIR/mono
#cd $DATA_DIR/mono
#wget http://www.statmt.org/wmt14/training-monolingual-europarl-v7/europarl-v7.en.gz
#gunzip europarl-v7.en.gz

