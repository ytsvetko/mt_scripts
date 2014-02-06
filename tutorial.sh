#!/bin/bash

install='######## Install Tools

./install_boost_locally.sh 
./install_kenlm.sh
./install_giza_pp.sh
./install_moses.sh
./install_cdec.sh

######## Prepare data
'
cd data/
./get_data.sh
./prepare_data.sh

######## Build LM

cd ../train_mt/
./train-klm.sh

######## Build Phrase-based MT - Moses

./train-moses.sh

######## Build Hiero - cdec

./train-cdec.sh

