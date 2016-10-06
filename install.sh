#!/bin/bash

#Unzip the experiments data
tar xzf experiments_data.tgz
tar xzf models.tgz 

##INSTALL IMS
wget -O- http://www.comp.nus.edu.sg/~nlp/sw/IMS_v0.9.2.1.tar.gz | tar xzf -
cd ims_0.9.2.1
wget -O- http://www.comp.nus.edu.sg/~nlp/sw/lib.tar.gz | tar xzf -
#Copying amended files
cp ../ims_amended_files/CLibLinearLexeltWriter.java ./src/sg/edu/nus/comp/nlp/ims/io/CLibLinearLexeltWriter.java
cp ../ims_amended_files/CStatistic.java ./src/sg/edu/nus/comp/nlp/ims/lexelt/CStatistic.java
#Recompiling IMS
rm ims.jar
make
cd ..


##INSTALL WORDNET3.0 database
wget -O- http://wordnetcode.princeton.edu/3.0/WordNet-3.0.tar.gz | tar xzf -
PATH_TO_WNDICT=`pwd`/WordNet-3.0/dict
sed -e "s|PATH_TO_DICT|$PATH_TO_WNDICT|g" prop_wn30.original.xml > prop_wn30.xml

#Download SemEval2013 test data
wget -q https://www.cs.york.ac.uk/semeval-2013/task12/data/uploads/datasets/semeval-2013-task12-test-data.zip
unzip semeval-2013-task12-test-data.zip
rm semeval-2013-task12-test-data.zip

#Convert the semeval data to IMS format
python semeval2013_to_allwords_format.py -i semeval-2013-task12-test-data -o semeval-2013-task12-test-data

#Give running permission
chmod +x *.sh

echo
echo "DO NOT FORGET TO UPDATE THE VARIABLE JAVA IN THE SCRIPTS train_ims.sh AND evaluate_semeval2013.sh"
echo
