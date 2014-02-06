#!/bin/bash

# Install Moses
# http://www.statmt.org/moses/

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
  WITH_BOOST="--with-boost=/opt/apps/gcc4_4/boost/1.51.0/"
else 
  WITH_BOOST="--with-boost=${TOOLS_DIR}/boost/1.51.0/"
fi

git clone -b RELEASE-2.1 https://github.com/moses-smt/mosesdecoder
cd mosesdecoder
./bjam --with-srilm=${TOOLS_DIR}/srilm \
       --with-giza=${TOOLS_DIR}/bin \
        ${WITH_BOOST} -j2


