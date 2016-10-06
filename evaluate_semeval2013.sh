#!/bin/bash

########################################################################
# Runs the classification of SemEval2013 for a given model and perfoms
# the evaluation using the official scorer
# Arguments:
#   + The path to the trained model
#   + The path to the file where you want to store the classification
# Example: evaluate_semeval2013.sh model_semcor output_exp0.txt
#
########################################################################

#!/bin/bash

## You might need to change this
JAVA="java -Xms8000m -Xmx16000m"

export LANG=en_US

here=`python -c 'import os,sys;print(os.path.dirname(os.path.realpath(sys.argv[1])))' $0`

model=$1
outfile=$2


test_file=$here/semeval-2013-task12-test-data/sem2013.aw.test.xml
lexelt_file=$here/semeval-2013-task12-test-data/sem2013.aw.test.lexelt
wn30_index=$here/WordNet-3.0/dict/index.sense
ims_folder=$here/ims_0.9.2.1
ldir=$ims_folder/lib
prop_wn30=$here/prop_wn30.xml
ldir=$ims_folder/lib
scorer=$here/semeval-2013-task12-test-data/scorer/scorer2
key=$here/semeval-2013-task12-test-data/keys/gold/wordnet/wordnet.en.key


CP=$ldir/weka-3.2.3.jar:$ldir/jwnl.jar:$ldir/commons-logging.jar:$ldir/jdom.jar:$ldir/trove.jar:$ldir/maxent-2.4.0.jar:$ldir/opennlp-tools-1.3.0.jar:$ldir/liblinear-1.33-with-deps.jar
CP=$CP:$ims_folder/ims.jar

#############################
#Calling to the IMS classifier
#############################

$JAVA -cp $CP sg.edu.nus.comp.nlp.ims.implement.CTester -ptm $ldir/tag.bin.gz -tagdict $ldir/tagdict.txt -ssm $ldir/EnglishSD.bin.gz -prop $prop_wn30 -c sg.edu.nus.comp.nlp.ims.corpus.CAllWordsFineTaskCorpus -r sg.edu.nus.comp.nlp.ims.io.CAllWordsResultWriter -is $wn30_index $test_file $model $model $outfile -f sg.edu.nus.comp.nlp.ims.feature.CAllWordsFeatureExtractorCombination -e sg.edu.nus.comp.nlp.ims.classifiers.CLibLinearEvaluator -lexelt $lexelt_file 2> /dev/null

#############################


##########################################
#Calling to the official semeval2013 scorer
##########################################

$scorer $outfile $key

##########################################


##########################################
# Calling to the the script to differentiate MFS/LFS
# which calls intternally to the official scorer
##########################################

python evaluate_mfs_lfs.py $key $scorer $outfile

##########################################
