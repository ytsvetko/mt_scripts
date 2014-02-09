#!/bin/bash

# Tools
TOOLS_DIR=$HOME/tools
SRILM=${TOOLS_DIR}/srilm/bin/i686-m64
TRAIN_LM=$SRILM/ngram-count 
TRAIN_LM_PARAM=" -gt1min 1 -gt2min 1 -gt3min 1 -gt4min 1 -kndiscount1 -kndiscount2 -kndiscount3 -kndiscount4"
COMPUTE_BEST_MIX=$SRILM/compute-best-mix
NGRAM=$SRILM/ngram

# LM Settings
LM_ORDER=4
DATA_DIR=$PWD/../data/data.tokenized
LM_DIR=$PWD/../lm
LM=${LM_DIR}/`basename ${DATA_DIR}`.${LM_ORDER}grams.arpa
PPL_DIR=${LM_DIR}/ppl
LOG_DIR=${LM_DIR}/log

# Dev corpus for tuning LMs interpolation weights
DEV=${DATA_DIR}/dev.es-en.en

# Textfiles and LMs for interpolation
text[${#text[*]}]=${DATA_DIR}/train.es-en.en
type[${#type[*]}]="text"                                                            

text[${#text[*]}]=${DATA_DIR}/test.es-en.en
type[${#type[*]}]="text"                                                         

############################################################

# Build language models for all test sources
mkdir -p ${LM_DIR} 
mkdir -p ${PPL_DIR}

for ((i=0;i<${#text[*]};i++)); do
   t=${text[${i}]}
   fname=${t//*\/}
   pplname[$i]="${PPL_DIR}/${fname}.ppl"
   lmname[$i]="${LM_DIR}/${fname}.txt"
   ppllog="${LOG_DIR}/${fname}.ppl.log"

   echo "building:${lmname[${i}]}" 
   echo "from: $t" 
   echo "type: ${type[${i}]}" 

  if [ "${type[${i}]}" == "text" ]; then  # Text
    gzip -dfc $t | ${TRAIN_LM} -order $LM_ORDER $TRAIN_LM_PARAM -text - -lm ${lmname[${i}]} 
  elif [ "${type[${i}]}" == "ngram" ]; then # Arpa file
    (gzip -dfc $t > ${lmname[${i}]})
  elif [ "${type[${i}]}" == "bigngram" ]; then # Large arpa file to prune 
    $NGRAM -order $LM_ORDER -lm $t -prune 1e-10 -write-lm ${lmname[${i}]} 
  else
    echo "\"${type[${i}]}\" is a totaly unknown type..." 
    exit 0
  fi
  
  echo "ppltest: ${pplname[${i}]}" 
  $NGRAM -order $LM_ORDER -debug 2 -lm "${lmname[${i}]}" -ppl $DEV >& "${pplname[${i}]}"
done

mixParam=""
mixOutput="${PPL_DIR}/best-mix.txt"
for ((i=0;i<${#text[*]};i++)); do
   mixParam="${mixParam} ${pplname[${i}]}"
done
echo "finding best mixing parameters"

$COMPUTE_BEST_MIX $mixParam >& $mixOutput
BEST_MIX=`cat $mixOutput | grep -Eo "best lambda \((.*)\)" | grep -Eo "\((.*)\)" | grep -Eo "[^()]*"`

intParam=""
for ((i=0;i<${#text[*]};i++)); do
   lambda[$i]=`echo ${BEST_MIX} | cut -f$((i + 1))  -d" "`
   echo -e "${lambda[${i}]} \t for ${lmname[${i}]}" 
   if [ "$i" == "0" ]; then
     intParam="$intParam -lm ${lmname[${i}]} -lambda ${lambda[${i}]}"
   elif [ "$i" = "1" ]; then 
     intParam="$intParam -mix-lm ${lmname[${i}]}"
   else
     intParam="$intParam -mix-lm$i ${lmname[${i}]} -mix-lambda$i ${lambda[${i}]}"
   fi
done

echo "Interpolating LMS"
$NGRAM -order $LM_ORDER -debug 2 $intParam -write-lm $LM 
$NGRAM -order $LM_ORDER -lm $LM -ppl $DEV

# ppl gives us the geometric average of 1/probability of each token, i.e., perplexity. 
# The exact expression is:
#	ppl = 10^(-logprob / (words - OOVs + sentences))


echo "done, have a nice day" 







