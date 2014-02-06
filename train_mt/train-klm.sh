#!/bin/bash

TOOLS_DIR=$HOME/tools
KENLM=${TOOLS_DIR}/kenlm/bin

CORPUS=../data/data.tokenized/train.es-en.en

LM_DIR=../lm
LM_ORDER=4
LM_NAME=train.${LM_ORDER}grams.arpa

# Build the language model
mkdir -p ${LM_DIR} 
${KENLM}/lmplz --order ${LM_ORDER} < ${CORPUS} > ${LM_DIR}/${LM_NAME}

# Compile the language model
${KENLM}/build_binary ${LM_DIR}/${LM_NAME} ${LM_DIR}/${LM_NAME}.klm

