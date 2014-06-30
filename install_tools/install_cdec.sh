#!/bin/bash

# Install cdec
# http://www.cdec-decoder.org/

TOOLS_DIR=$HOME/tools
mkdir -p ${TOOLS_DIR}
cd ${TOOLS_DIR}

# path to boost
if [ `uname -n` == "allegro.clab.cs.cmu.edu" ] ; then
  module load boost-1.54.0
elif [ `uname -n` == "workhorse.lti.cs.cmu.edu" ] ; then
  module load clab-gcc
  module load clab-boost
elif [[ `uname -n` == *stampede.tacc* ]] ; then
  module load boost
  WITH_BOOST="--with-boost=/opt/apps/gcc4_4/boost/1.51.0"
else 
  WITH_BOOST="--with-boost=${TOOLS_DIR}/boost_1_51_0"
fi

rm -rf cdec
wget http://demo.clab.cs.cmu.edu/cdec/cdec-2014-06-15.tar.gz
tar -xzvf cdec-2014-06-15.tar.gz
ln -s cdec-2014-06-15 cdec
cd cdec
./configure ${WITH_BOOST}
make -j 4 
make check
./tests/run-system-tests.pl

cd python
sudo python setup.py install

