#!/bin/bash

#Install Giza++ 
# https://giza-pp.googlecode.com/files/giza-pp-v1.0.7.tar.gz

TOOLS_DIR=$HOME/tools
mkdir -p ${TOOLS_DIR}
cd ${TOOLS_DIR}

wget https://giza-pp.googlecode.com/files/giza-pp-v1.0.7.tar.gz
tar -xzvf giza-pp-v1.0.7.tar.gz

cd $TOOLS_DIR/giza-pp
make

cd ../
mkdir -p bin
cp giza-pp/GIZA++-v2/GIZA++ bin/
cp giza-pp/mkcls-v2/mkcls bin/
cp giza-pp/GIZA++-v2/snt2cooc.out bin/


