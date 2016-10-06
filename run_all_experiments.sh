#!/bin/bash


FOLDER_WITH_EXPS=experiments_data
NUM_PROC=15


#Clean all the previous data
rm -rf ./evaluation 2> /dev/null
rm -rf ./models 2> /dev/null
rm part*.out part*.err 2> /dev/null

mkdir evaluation models


for this_exp_input_folder in $FOLDER_WITH_EXPS/B*
do
  basename=`basename $this_exp_input_folder`
  echo Running training $basename `date`
  
  
  #Run the training
  train_ims_paralel.sh $this_exp_input_folder  models/$basename $NUM_PROC
  
  #Wait for completion
  num_done=0
  while [ "$num_done" -ne "$NUM_PROC" ]; 
  do 
    echo "    Done $num_done at `date`"
    sleep 60; 
    num_done=`tail -n 1 part*out | grep '^END ' | wc -l`; 
  done
  
  rm part*.out part*.err
  echo "Training done $basename"
  
  
  ## Running the evaluation
  echo Running evaluation
  evaluate_semeval2013.sh models/$basename evaluation/$basename.out > evaluation/$basename.figures.txt
done

echo ALL DONE `date`
