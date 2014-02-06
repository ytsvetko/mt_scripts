#!/bin/bash

#Install SRILM
# http://www.speech.sri.com/projects/srilm/download.html

TOOLS_DIR=$HOME/tools
mkdir -p ${TOOLS_DIR}
cd ${TOOLS_DIR}

mkdir srilm
cd srilm

# (get srilm download 1.5.7, requires web registration, you'll end up with a .tgz file to copy to this directory)

tar -xvzf srilm.tgz

# edit path to SRILM in the Makefile:
# old line - '# SRILM = /home/speech/stolcke/project/srilm/devel'
# new line - 'SRILM = '$PWD

make World

export PATH=${PATH_TO_SRI}/bin/i686-m64:${PATH_TO_SRI}/bin:$PATH

