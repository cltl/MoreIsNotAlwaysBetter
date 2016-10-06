#!/usr/bin/env python

from nltk.corpus import wordnet

import sys
import tempfile
import subprocess
import os


def load_file(this_file):
    keys_for_id = {}
    fd = open(this_file)
    for line in fd:
        tokens = line.strip().split(' ')
        keys_for_id[tokens[1]] = tokens[2:]
    fd.close()
    return keys_for_id

def get_first_sense(this_lemma, this_pos):
    lemmas = wordnet.lemmas(this_lemma,this_pos)
    return lemmas[0].key()


def evaluate(list_ids, gold_keys, system_keys, SCORER):
    key_fd = tempfile.NamedTemporaryFile('w', delete=False)
    system_fd = tempfile.NamedTemporaryFile('w', delete=False)
    for this_id in sorted(list(list_ids)):
        doc_id = this_id[:this_id.find('.')]
        key_fd.write('%s %s %s\n' % (doc_id, this_id,' '.join(gold_keys[this_id])))
        system_fd.write('%s %s %s\n' % (doc_id, this_id,' '.join(system_keys[this_id])))
    key_fd.close()
    system_fd.close()
    
    cmd = []
    cmd.append(SCORER)
    cmd.append(system_fd.name)
    cmd.append(key_fd.name)
    out = subprocess.check_output(cmd)
    precision = recall = attempted = 0
    for line in out.splitlines():
        tokens = line.strip().split(b' ')
        if len(tokens)!= 0:
            if tokens[0]==b'precision:':
                precision = float(tokens[1])*100.0
            elif tokens[0]==b'recall:':
                recall = float(tokens[1])*100.0
            elif tokens[0]==b'attempted:':
                attempted = float(tokens[1])
    os.remove(system_fd.name)
    os.remove(key_fd.name)

    return (precision, recall, attempted)
    
        
    
if __name__ == '__main__':
    path_to_key = sys.argv[1]
    SCORER = sys.argv[2]
    wsd_outfile = sys.argv[3]
    
    gold_keys_for_id = load_file(path_to_key)
    
    system_keys_for_id = load_file(wsd_outfile)
    
    mfs_ids = set()
    lfs_ids = set()
    
    
    for this_id, list_keys in gold_keys_for_id.items():
        one_key = list_keys[0]
        lemma = one_key[:one_key.find('%')]
        mfs = get_first_sense(lemma,'n')
        if mfs in list_keys:
            mfs_ids.add(this_id)
        else:
            lfs_ids.add(this_id)
         
    all_ids = mfs_ids | lfs_ids   
            
    precision_mfs, recall_mfs, attempted_mfs = evaluate(mfs_ids, gold_keys_for_id, system_keys_for_id, SCORER)
    precision_lfs, recall_lfs, attempted_lfs = evaluate(lfs_ids, gold_keys_for_id, system_keys_for_id, SCORER)
    precision_all, recall_all, attempted_all = evaluate(all_ids, gold_keys_for_id, system_keys_for_id, SCORER)
    
    print('MFS evaluation, instances=%d attempted=%.2f' % (len(mfs_ids), attempted_mfs))
    print('\tPrecision: %.2f' % precision_mfs)
    print('\tRecall   : %.2f' % recall_mfs)
    print('\nLFS evaluation, instances=%d attempted=%.2f' % (len(lfs_ids), attempted_lfs)) 
    print('\tPrecision: %.2f' % precision_lfs)
    print('\tRecall   : %.2f' % recall_lfs)
    print('\nALL evaluation, instances=%d attempted=%.2f' % (len(all_ids), attempted_all)) 
    print('\tPrecision: %.2f' % precision_all)
    print('\tRecall   : %.2f' % recall_all)
    print('\nAverage MFS/LFS:')
    print('\tPrecision: %.2f' % ((precision_mfs+precision_lfs)/2.0))
    print('\tRecall   : %.2f' % ((recall_mfs + recall_lfs) / 2.0))
            
    
        
        
        