# Running GeneValidator with sample data

Here, we walk through the steps involved in analysing some sample data with GeneValidator. There are two options on how to run genevalidator - the second option is faster with larger input files.

## Expected Results

<strong>protein_data.fasta</strong> [See here](http://wurmlab.github.io/tools/genevalidator/examplar_data/protein_input/)
<strong>mrna_data.fasta</strong> [See here](http://wurmlab.github.io/tools/genevalidator/examplar_data/genetic_input/) 

##### Running GeneValidator with a  Database, with four threads

```bash
$ genevalidator -d 'local-or-remote-BLAST-db' -n num_threads input_file

e.g.

$ genevalidator -d '/home/ismailm/blastdb/SwissProt' -n 4 protein_data.fasta
$ genevalidator -d '/home/ismailm/blastdb/SwissProt' -n 4 mrna_data.fasta
$ genevalidator -d 'swissprot -remote' -n 4 protein_data.fasta
$ genevalidator -d 'swissprot -remote' -n 4 mrna_data.fasta

```
This will produce a yaml file (in the same directory as the input file) and html file (within a subdirectory in the directory of the input files). 


##### Running GeneValidator with a pre-computed BLAST XML file

```bash
$  genevalidator -d 'local-or-remote-BLAST-db' -x 'Path-to-XML-file' Input_File

e.g.
$  genevalidator -d '/home/ismailm/blastdb/SwissProt' -x 'protein_data.fasta.blast_xml' protein_data.fasta
$  genevalidator -d '/home/ismailm/blastdb/SwissProt' -x 'mrna_data.fasta.blast_xml' mrna_data.fasta

```

##### Running GeneValidator with a pre-computed BLAST tabular file 

```bash
$ blast(x/p)
$ genevalidator -d 'local-or-remote-BLAST-db' -t 'Path-to-tabular-file' -o 'tabular_file_format-(BLAST_option-out_fmt)' Input_File 

e.g.
$ genevalidator -d '/home/ismailm/blastdb/SwissProt' -t 'protein_data.fasta.blast_tabular' -o 'qseqid sseqid sacc slen qstart qend sstart send length qframe pident evalue' protein_data.fasta 
$ genevalidator -d '/home/ismailm/blastdb/SwissProt' -t 'mrna_data.fasta.blast_tabular' -o 'qseqid sseqid sacc slen qstart qend sstart send length qframe pident evalue' mrna_data.fasta 
```

##### Running GeneValidator with the fast option 

```bash
$ genevalidator -d 'local-or-remote-BLAST-db' -n 2 -f Input_File

e.g.
$ genevalidator -d '/home/ismailm/blastdb/SwissProt' -n 4 -f protein_data.fasta
$ genevalidator -d '/home/ismailm/blastdb/SwissProt' -n 4 -f mrna_data.fasta

```