#!/bin/bash

## You might need to change this

JAVA="java -Xms8000m -Xmx16000m"

export LANG=en_US

here=`python -c 'import os,sys;print(os.path.dirname(os.path.realpath(sys.argv[1])))' $0`

#Uncomment this for the not paralel
#input_word_list=$here/sem2013.lemma_pos.list
input_word_list=$3
input_folder=$1
model_folder=$2

#Uncomment this for the non paralel
#rm -rf $model_folder 2> /dev/null
#mkdir $model_folder

bdir=$here/ims_0.9.2.1/
libdir=$bdir/lib
CP=$libdir/liblinear-1.33-with-deps.jar:$libdir/jwnl.jar:$libdir/commons-logging.jar:$libdir/jdom.jar:$libdir/trove.jar:$libdir/maxent-2.4.0.jar:$libdir/opennlp-tools-1.3.0.jar
CP=$CP:$bdir/ims.jar 
PROP=$here/prop_wn30.xml

echo "START `date` for file $input_word_list"

while read item; 
do
  xml=$input_folder/$item.train.xml
  key=$input_folder/$item.train.key
  if [ -e $xml ];
  then
  
    echo Training $item
    $JAVA -cp $CP sg.edu.nus.comp.nlp.ims.implement.CTrainModel -prop $PROP -ptm $libdir/tag.bin.gz -tagdict $libdir/tagdict.txt -ssm $libdir/EnglishSD.bin.gz $xml $key $model_folder -f sg.edu.nus.comp.nlp.ims.feature.CFeatureExtractorCombination -s2 0 -c2 0 
    model_file=$model_folder/$item.model.gz
    stats_file=$model_folder/$item.stat.gz
    wc -l $model_file
    wc -l $stats_file
    echo
  else
    echo File $xml does not exist. Models not trained
  fi
done < $input_word_list
          
echo END `date`
