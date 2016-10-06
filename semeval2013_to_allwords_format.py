#!/usr/bin/env python

from __future__ import print_function

'''
Given the original semeval2013 WSD multilingual all word task (#12) it converts the files (for English) to the SV2 and SV3 all
words format (as it is used by IMS). It also creates a file called "lexelt" which basically is a file with the lemma and pos
for every instance id. We need to filter by the ids, as not all the <instance> objects are annotated with wordnet synsets
'''

import sys
import os
import argparse
from lxml import etree
from xml.sax.saxutils import escape



def do_conversion(path_to_semeval, path_to_out, these_ids):
    fout = open(path_to_out,'w')
    
    my_tree = etree.parse(path_to_semeval)
    is_the_first_text = True
    fout.write('<?xml version="1.0"?>\n')
    fout.write('<corpus lang="en">\n')
    for text_node in my_tree.findall('text'):
        if not is_the_first_text:
            fout.write('</text>\n')
        is_the_first_text = False
        fout.write('<text id="%s">\n' % text_node.get('id'))
        for sentence_node in text_node.findall('sentence'):
            for leaf_node in sentence_node:
                if leaf_node.tag == 'instance':
                    instance_id = leaf_node.get('id')
                    if instance_id in these_ids:
                        fout.write('<head id="%s">%s</head>\n' % (leaf_node.get('id'), escape(leaf_node.text)))
                    else:
                        fout.write('%s\n' % escape(leaf_node.text))
                elif leaf_node.tag == 'wf':
                    fout.write('%s\n' % escape(leaf_node.text))
    fout.write('</text>\n')
    fout.write('</corpus>\n')

def create_lexelt_file(path_to_key,path_to_out, path_to_lemma_out):
    fout = open(path_to_out,'w')
    
    selected_ids = []
    mapping_pos = {'1':'n', '2':'v','3':'a','4':'r','5':'a'}
    set_lemmas_pos = set()
    fd = open(path_to_key)
    for line in fd:
        fields = line.strip().split()
        this_id = fields[1]
        this_lexkey = fields[2]
        p = this_lexkey.find('%')
        wn_pos = this_lexkey[p+1]
        short_pos = mapping_pos[wn_pos]
        lemma = this_lexkey[:p]
        selected_ids.append(this_id)
        fout.write('%s %s.%s\n' % (this_id, lemma, short_pos))
        set_lemmas_pos.add('%s.%s' % (lemma, short_pos))
    fout.close()
    fd.close()
    
    fl = open(path_to_lemma_out,'w')
    for s in sorted(list(set_lemmas_pos)):
        fl.write('%s\n' % s)
    fl.close()
    return selected_ids

           
    
if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Converts semeval2013 to traditional all words format')
    parser.add_argument('-v', action='version', version = '1.0')
    parser.add_argument('-i', dest='sem2013_folder', required=True, help='Path to Semeval2013 data folder')
    parser.add_argument('-o', dest='output_folder', required=True, help='Path to the desired output folder')    
    args = parser.parse_args()
       
    #os.mkdir(args.output_folder)
    xml_out = os.path.join(args.output_folder,'sem2013.aw.test.xml')
    lexelt_out = os.path.join(args.output_folder,'sem2013.aw.test.lexelt')
    lemma_pos_out = os.path.join(args.output_folder,'sem2013.aw.test.lemma.pos.list')
    path_to_key = os.path.join(args.sem2013_folder,'keys', 'gold','wordnet','wordnet.en.key')
    path_to_xml = os.path.join(args.sem2013_folder,'data','multilingual-all-words.en.xml')

    selected_ids = create_lexelt_file(path_to_key,lexelt_out, lemma_pos_out)
    print('Lexelt file in %s' % lexelt_out)
    print('File with list of lemma.pos in %s' % lemma_pos_out)
    print('Number of ids in key: %d' % len(selected_ids))
    
    do_conversion(path_to_xml, xml_out, selected_ids)
    print('XML file with allwords format in %s' % xml_out)