#!/bin/bash

######## Tools

TOOLS_DIR=$HOME/tools

# moses scripts
MOSES_DIR=$TOOLS_DIR/mosesdecoder
MOSES_TRAIN=${MOSES_DIR}/scripts/training/train-model.perl
MERT_DIR=${MOSES_DIR}/mert
MERT=${MOSES_DIR}/scripts/training/mert-moses.pl
MOSES=${MOSES_DIR}/bin/moses
MOSES_FILTER=${MOSES_DIR}/scripts/training/filter-model-given-input.pl
BLEU=${MOSES_DIR}/scripts/generic/multi-bleu.perl


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


SYSTEM_DIR=$PWD/../systems/moses
mkdir -p ${SYSTEM_DIR}

DO_TRAIN=1
DO_TUNE=1
DO_DECODE=1
DO_EVAL=1

######## Build Moses model

if (( ${DO_TRAIN} )); then

  #$MOSES_TRAIN --help
  $MOSES_TRAIN --root-dir ${SYSTEM_DIR} --corpus ${CORPUS_DIR}/${TRAIN} \
      --f ${SRC_LNG} --e ${TRG_LNG} --alignment grow-diag-final-and \
      --external-bin-dir ${TOOLS_DIR}/bin \
      --reordering msd-bidirectional-fe --lm 0:4:$LM --first-step 1 
fi

######## Tune weights

if (( ${DO_TUNE} )); then

  TUNE_DIR=${SYSTEM_DIR}/mert
  rm -rf ${TUNE_DIR}
  mkdir -p ${TUNE_DIR}
  $MERT ${CORPUS_DIR}/${DEV}.${SRC_LNG} \
        ${CORPUS_DIR}/${DEV}.${TRG_LNG} \
        $MOSES ${SYSTEM_DIR}/model/moses.ini \
        --working-dir ${TUNE_DIR} --mertdir $MERT_DIR 
fi

######## Decode

if (( ${DO_DECODE} )); then

  TEST_DIR=${SYSTEM_DIR}/test
  rm -rf ${TEST_DIR}
  mkdir -p ${TEST_DIR}
  SRC_FILE=${CORPUS_DIR}/${TEST}.${SRC_LNG}
  TRG_REF_FILE=${CORPUS_DIR}/${TEST}.${TRG_LNG}
  TRG_OUT_FILE=${TEST_DIR}/`basename ${TRG_REF_FILE}`".out"

  # Translate ${SRC_FILE}
  rm -rf ${TEST_DIR}/filtered
  $MOSES_FILTER ${TEST_DIR}/filtered ${SYSTEM_DIR}/mert/moses.ini ${SRC_FILE}
  $MOSES -f ${TEST_DIR}/filtered/moses.ini < ${SRC_FILE} > ${TRG_OUT_FILE}
fi


######## Evaluate translation

if (( ${DO_EVAL} )); then

  TRG_REF_FILE=${CORPUS_DIR}/${TEST}.${TRG_LNG}
  TRG_OUT_FILE=${TEST_DIR}/`basename ${TRG_REF_FILE}`".out"
  OUT_BLEU_FILE=${TEST_DIR}/`basename ${TRG_REF_FILE}`".bleu"

  $BLEU ${TRG_REF_FILE} < ${TRG_OUT_FILE} > ${OUT_BLEU_FILE}

  cat ${OUT_BLEU_FILE}
fi

