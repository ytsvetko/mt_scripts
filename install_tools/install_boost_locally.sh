#!/bin/bash

#Install boost 1.5.1 locally in $HOME/tools/boost

TOOLS_DIR=$HOME/tools
mkdir -p ${TOOLS_DIR}
cd ${TOOLS_DIR}

wget http://downloads.sourceforge.net/project/boost/boost/1.51.0/boost_1_51_0.tar.gz
tar -xvzf boost_1_51_0.tar.gz
cd boost_1_51_0
./bootstrap.sh
./b2 --with=all --layout=tagged --prefix=$TOOLS_DIR/boost -j 4 install threading=multi

