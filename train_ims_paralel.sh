#!/bin/bash


input_word_list=sem2013.lemma_pos.list
input_folder=$1
model_folder=$2
N=$3

rm -rf $model_folder
mkdir $model_folder



tmp_folder=`mktemp -d`

# How many lines to put in every part
total_lines=$(wc -l $input_word_list | cut -d' ' -f1)
num_lines_per_part=$(($total_lines/$N +1))

split -l $num_lines_per_part -d $input_word_list $tmp_folder/part

for file in $tmp_folder/*
do
  base_file=`basename $file`.$$
  echo
  echo "Running training for $file with logs in $base_file.*"
  train_ims.sh $input_folder $model_folder $file > $base_file.out 2> $base_file.err &
done

# If we dont wait a bit here and we remove the folder, some subprocess might give a "not file found" error
sleep 15
rm -rf $tmp_folder
