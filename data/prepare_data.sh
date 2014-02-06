#!/bin/bash

set -x 

# Tokenize and lowercase the training, dev, devtest data

TOOLS_DIR=$HOME/tools
CDEC=$TOOLS_DIR/cdec

SRC_LNG=es
TRG_LNG=en

TRAIN=train.${SRC_LNG}-${TRG_LNG}
DEV=dev.${SRC_LNG}-${TRG_LNG}
TEST=test.${SRC_LNG}-${TRG_LNG}

DATA_DIR=cdec-spanish-demo
TOKENIZED_DIR=data.tokenized
mkdir -p ${TOKENIZED_DIR}

# Tokenize and lowercase
${CDEC}/corpus/tokenize-anything.sh < ${DATA_DIR}/training/news-commentary-v7.es-en | ${CDEC}/corpus/lowercase.pl > ${TOKENIZED_DIR}/${TRAIN}
# Filter training corpus sentence lengths
${CDEC}/corpus/filter-length.pl -80 ${TOKENIZED_DIR}/${TRAIN} > ${TOKENIZED_DIR}/${TRAIN}.filtered
# Split into 2 files (for Moses)
${CDEC}/corpus/cut-corpus.pl 1 ${TOKENIZED_DIR}/${TRAIN}.filtered > ${TOKENIZED_DIR}/${TRAIN}.${SRC_LNG}
${CDEC}/corpus/cut-corpus.pl 2 ${TOKENIZED_DIR}/${TRAIN}.filtered > ${TOKENIZED_DIR}/${TRAIN}.${TRG_LNG}

${CDEC}/corpus/tokenize-anything.sh < ${DATA_DIR}/dev/2010.es-en | ${CDEC}/corpus/lowercase.pl > ${TOKENIZED_DIR}/${DEV}
${CDEC}/corpus/cut-corpus.pl 1 ${TOKENIZED_DIR}/${DEV} > ${TOKENIZED_DIR}/${DEV}.${SRC_LNG}
${CDEC}/corpus/cut-corpus.pl 2 ${TOKENIZED_DIR}/${DEV} > ${TOKENIZED_DIR}/${DEV}.${TRG_LNG}

${CDEC}/corpus/tokenize-anything.sh < ${DATA_DIR}/devtest/2011.es-en | ${CDEC}/corpus/lowercase.pl > ${TOKENIZED_DIR}/${TEST}
${CDEC}/corpus/cut-corpus.pl 1 ${TOKENIZED_DIR}/${TEST} > ${TOKENIZED_DIR}/${TEST}.${SRC_LNG}
${CDEC}/corpus/cut-corpus.pl 2 ${TOKENIZED_DIR}/${TEST} > ${TOKENIZED_DIR}/${TEST}.${TRG_LNG}


