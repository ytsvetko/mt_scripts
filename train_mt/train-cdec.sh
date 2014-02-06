#!/bin/bash

######## Tools

TOOLS_DIR=$HOME/tools

# cdec
CDEC=${TOOLS_DIR}/cdec
export PYTHONPATH=`echo ${CDEC}/python/build/lib.*`

NUM_CPU=2

######## Data

SRC_LNG=es
TRG_LNG=en

# Corpora
CORPUS_DIR=$PWD/../data/data.tokenized
TRAIN=train.${SRC_LNG}-${TRG_LNG}
DEV=dev.${SRC_LNG}-${TRG_LNG}
TEST=test.${SRC_LNG}-${TRG_LNG}

# LM
LM_DIR=$PWD/../lm
LM_ORDER=4
LM=$LM_DIR/train.${LM_ORDER}grams.arpa.klm


SYSTEM_DIR=$PWD/../systems/cdec
mkdir -p ${SYSTEM_DIR}

DO_ALIGN=1
DO_TRAIN=1
DO_TUNE=1
DO_TEST=1

if (( ${DO_ALIGN} )); then
  # Run bidirectional word alignments using fast_align. 
  mkdir -p ${SYSTEM_DIR}/data.aligned
  ${CDEC}/word-aligner/fast_align -i ${CORPUS_DIR}/${TRAIN}.filtered -d -v -o -p ${SYSTEM_DIR}/data.aligned/${TRAIN}.aligned.fwd.probs > ${SYSTEM_DIR}/data.aligned/${TRAIN}.aligned.fwd
  ${CDEC}/word-aligner/fast_align -i ${CORPUS_DIR}/${TRAIN}.filtered -d -v -o -r -p ${SYSTEM_DIR}/data.aligned/${TRAIN}.aligned.rev.probs > ${SYSTEM_DIR}/data.aligned/${TRAIN}.aligned.rev
  ${CDEC}/utils/atools -i ${SYSTEM_DIR}/data.aligned/${TRAIN}.aligned.fwd -j ${SYSTEM_DIR}/data.aligned/${TRAIN}.aligned.rev -c grow-diag-final-and > ${SYSTEM_DIR}/data.aligned/${TRAIN}.aligned.gdfa

  # To visualize alignments
  ${CDEC}/utils/atools -i ${SYSTEM_DIR}/data.aligned/${TRAIN}.aligned.gdfa -c display > ${SYSTEM_DIR}/data.aligned/${TRAIN}.aligned.gdfa.display
fi

if (( ${DO_TRAIN} )); then
  # Compile the training data
  python -m cdec.sa.compile -b ${CORPUS_DIR}/${TRAIN}.filtered -a ${SYSTEM_DIR}/data.aligned/${TRAIN}.aligned.gdfa -c ${SYSTEM_DIR}/extract.ini -o ${SYSTEM_DIR}/training.sa

  # Extract grammars for the dev and devtest sets
  python -m cdec.sa.extract -c ${SYSTEM_DIR}/extract.ini -g ${SYSTEM_DIR}/grammars.dev -j ${NUM_CPU} -z < ${CORPUS_DIR}/${DEV} > ${SYSTEM_DIR}/${DEV}.sgm
  python -m cdec.sa.extract -c ${SYSTEM_DIR}/extract.ini -g ${SYSTEM_DIR}/grammars.test -j ${NUM_CPU} -z < ${CORPUS_DIR}/${TEST} > ${SYSTEM_DIR}/${TEST}.sgm
fi

if (( ${DO_TUNE} )); then
  ${CDEC}/training/dpmert/dpmert.pl --output-dir ${SYSTEM_DIR}/mert -w weights.init -d ${SYSTEM_DIR}/${DEV}.sgm -c cdec.ini -j ${NUM_CPU}
fi

if (( ${DO_TEST} )); then
  # eval mert
  ${CDEC}/training/utils/decode-and-evaluate.pl --dir ${SYSTEM_DIR}/test -c cdec.ini -w ${SYSTEM_DIR}/mert/weights.final -i ${SYSTEM_DIR}/${TEST}.sgm -j ${NUM_CPU}
fi

