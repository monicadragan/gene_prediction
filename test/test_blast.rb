require_relative 'test_helper'
require 'minitest/autorun'
require 'fileutils'
require 'genevalidator'
require 'genevalidator/blast'
require 'genevalidator/tabular_parser'

module GeneValidator
  class TestBlastClass < Minitest::Test
    dir = 'test/test_files'
    filename_mrna     = "#{dir}/file_mrna.txt"
    filename_prot     = "#{dir}/file_prot.txt"
    filename_fasta    = "#{dir}/test_validations.fasta"
    mixed_fasta       = "#{dir}/mixed_type.fasta"
    filename_prot_xml = "#{dir}/output.xml"
    output_tab7       = "#{dir}/output.tab.7"
    output_tab6       = "#{dir}/output.tab.6"
    output_tab_mixed  = "#{dir}/output.tab.6.mixed"
    ncbi_mrna_tab20   = "#{dir}/ncbi_mrna.tab.20"
    ncbi_mrna_xml20   = "#{dir}/ncbi_mrna.xml.20"

    describe 'Test Blast Class' do

      it 'should detect nucleotide seq type' do

        file_mrna = File.open(filename_mrna, 'w+')
        query_mrna = 'ATGGCTAAATTACAGAGGAAGAGAAGCAAGGCTCTTGGGTCATCTCTAGAGATGT' \
                     'CCCAGATAATGGATGCAGGAACAAACAAAATTAAAAGAAGAATAAGAGATTTAGA' \
                     'GAGGTTATTAAAAAAGAAGAAAGATATACTTCCATCCACAGTAATAATAGAAAAG' \
                     'GAAAGAAATTTGCAAGCTTTACGGTTGGAATTGCAGAATAATGAACTCAAGAATA' \
                     'AGATTAAAGCCAACGCTAAAAAATATCATATGGTGAGATTCTTTGAAAAAAAAAA' \
                     'AGCATTGAGAAAATATAACAGATTATTGAAGAAAATAAAAGAATCTGGCGCAGAT' \
                     'GATAAAGATTTACAACAAAAGTTGAGAGCCACTAAAATTGAATTATGTTACGTGA' \
                     'TAAATTTTCCCAAAACTGAAAAGTATATTGCACTATATCCGAATGATACACCATC' \
                     'TACAGACCCAAAGGCGTAG'
        file_mrna.puts('>seq1')
        file_mrna.puts(query_mrna)
        file_mrna.close

        FileUtils.rm_rf("#{filename_mrna}.html") rescue Error

        default_opt = {
          input_fasta_file: filename_mrna,
          validations: ['all'],
          db: 'swissprot -remote',
          num_threads: 1
        }

        val = GeneValidator::Validation.new(default_opt)

        File.delete(filename_mrna)
        FileUtils.rm_rf("#{filename_mrna}.html")
        assert_equal(:nucleotide, val.type)
      end

      it 'should detect protein type' do
        file_prot = File.open(filename_prot, 'w+')
        query_prot = 'MPSKKQYNLVHNDEYDTRIPLHSEEAFHRGIVFHAKFIGSMEVPRPTSRVEIVAA' \
                     'MRRIRYEFKAKGIKKKKVTLEVSVDGLKVTLRKKKKKQQQWMDENKIYLMHHPIY' \
                     'RIFYVSHDSHDLKIFSYIARDGSSNTFKCNVFKSSKKKKQQQWMDENKIYLMHHP' \
                     'IYRIFYVSHDSHDLKIFSYIARDGSSNTFKCNVFKSSKKSQAMRVVRTVGQAFEV' \
                     'CHKLSLNNATEERDRGEKEREREHGENHRDVYEDQDEIPNVQSQPSPSSVHKDIS' \
                     'LLGDTEDSAPEQTTVPCLLRSHEVPATTASTSPIRQSPSGTVTSDCGGLLVGGEL' \
                     'TALKHEIQLLRERLEQQSQQTRAAVAHARLLQDQLAAETAARVEAQARTHQLLMQ' \
                     'NKELLEHISALVGHLREQERISSGHVTSQSQLPGSAAIQQTTTVPDLSNLGQSLS' \
                     'YPGNLSTIGIQGNSNTDQLQFQAQLLERLHNISPYQPQRSPYNTPSPYTMGPSLL' \
                     'VPPNNIPTNSAQLSPSHSMSLRVSQSNSFSSSPIMTHKLDNYVGNTENTEYKSTF' \
                     'IKPIPCTNERNVNHEAVGKQDRNNLHEEIPPIVLDPPPQGKRSETTPKHVPTKEN' \
                     'LNGQISSKNVQKNLATILRTTGPPPSRTTSARLPSRNDLMSEVQRTTWARHTTK'
        file_prot.puts('>seq2')
        file_prot.puts(query_prot)
        file_prot.close

        FileUtils.rm_rf("#{filename_prot}.html") rescue Error

        default_opt = {
          input_fasta_file: filename_prot,
          validations: ['all'],
          db: 'swissprot -remote',
          num_threads: 1
        }

        val = GeneValidator::Validation.new(default_opt)

        File.delete(filename_prot)
        FileUtils.rm_rf("#{filename_prot}.html")
        assert_equal(:protein, val.type)

      end

      it 'should raise error when input types are mixed in the fasta' do
        mixed = false
        begin
          original_stderr = $stderr
          $stderr.reopen('/dev/null', 'w')

          FileUtils.rm_rf("#{filename_prot}.html") rescue Error

          default_opt = {
            input_fasta_file: mixed_fasta,
            validations: ['all'],
            db: 'swissprot -remote',
            num_threads: 1
          }

          GeneValidator::Validation.new(default_opt)
        rescue SystemExit => e
          mixed = true
        end
        $stderr = original_stderr
        assert_equal(true, mixed)
      end

      it 'should parse xml input' do
        output = File.open(filename_prot_xml, 'rb').read
        iterator = Bio::BlastXMLParser::NokogiriBlastXml.new(output).to_enum
        hits = BlastUtils.parse_next_query_xml(iterator, :protein)
        assert_equal(500, hits.length)
        assert_equal(870, hits[19].length_protein)
        assert_equal('XP_004524940', hits[19].accession_no)
        assert_equal(3, hits[19].hsp_list.length)
        assert_equal(703, hits[19].hsp_list[2].hit_from)
      end

      it 'should parse tabular -6 input with default tabular format' do

        output = File.open(ncbi_mrna_tab20, 'rb').read
        tabular_headers = 'qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore'
        iterator_tab = TabularParser.new(ncbi_mrna_tab20, tabular_headers, :protein)
        hits = iterator_tab.parse_next

        assert_equal(20, hits.length)
        assert_equal(1, hits[0].hsp_list.length)
        assert_equal(111, hits[0].hsp_list[0].hit_to)
        assert(hits[0].hsp_list[0].hit_from.is_a? Fixnum)

        assert_equal(100, hits[0].hsp_list[0].pidentity)
        assert(hits[0].hsp_list[0].pidentity.is_a? Float)

        assert_equal(2.0e-44, hits[0].hsp_list[0].hsp_evalue)
        assert(hits[0].hsp_list[0].hsp_evalue.is_a? Float)
      end

      it 'should parse tabular -6 input with tabular format as argument' do
        output = File.open(output_tab6, 'rb').read
        tabular_headers = 'qseqid sseqid sacc slen qstart qend sstart send pident length qframe evalue'
        iterator_tab = TabularParser.new(output_tab6, tabular_headers, :protein)
        hits = iterator_tab.parse_next
        assert_equal(4, hits.length)
        assert_equal(199, hits[0].length_protein)
        assert_equal('EFZ19000', hits[0].accession_no)
        assert_equal(3, hits[0].hsp_list.length)
        assert_equal(100, hits[0].hsp_list[2].hit_to)
      end

      it 'should parse tabular -6 input with mixed columns' do
        output = File.open(output_tab_mixed, 'rb').read
        tabular_headers = 'qend sstart send pident length qframe evalue qseqid sseqid sacc slen qstart'
        iterator_tab = TabularParser.new(output_tab_mixed, tabular_headers, :protein)
        hits = iterator_tab.parse_next
        assert_equal(4, hits.length)
        assert_equal(199, hits[0].length_protein)
        assert_equal('EFZ19000', hits[0].accession_no)
        assert_equal(3, hits[0].hsp_list.length)
        assert_equal(100, hits[0].hsp_list[2].hit_to)
      end

      it 'should parse tabular -7 input' do
        output = File.open(output_tab7, 'rb').read
        tabular_headers = 'qseqid sseqid sacc slen qstart qend sstart send length qframe evalue'
        iterator_tab = TabularParser.new(output_tab7, tabular_headers, :protein)
        hits = iterator_tab.parse_next
        assert_equal(4, hits.length)
        assert_equal(199, hits[0].length_protein)
        assert_equal('EFZ19000', hits[0].accession_no)
        assert_equal(3, hits[0].hsp_list.length)
        assert_equal(100, hits[0].hsp_list[2].hit_to)
      end

      it 'should remove identical matches among protein sequences' do
        output = File.open(output_tab6, 'rb').read

        FileUtils.rm_rf("#{filename_fasta}.html") rescue Error

        default_opt = {
          input_fasta_file: filename_fasta,
          validations: ['all'],
          db: 'swissprot -remote',
          num_threads: 1
        }

        b = GeneValidator::Validation.new(default_opt) # just use a valida filename to create the object
        prediction = Sequence.new
        prediction.length_protein = 1808
        tabular_headers = 'qseqid sseqid sacc slen qstart qend sstart send pident length qframe evalue'
        iterator_tab = TabularParser.new(output_tab6, tabular_headers, :protein)
        iterator_tab.parse_next
        hits = iterator_tab.parse_next

        # before removal
        assert_equal(2, hits.length)
        assert_equal(100, hits[0].hsp_list[0].pidentity)
        assert_in_delta(99.23, hits[0].hsp_list[1].pidentity, 0.01)
        assert_in_delta(90, hits[1].hsp_list[0].pidentity, 0.01)
        hits = b.remove_identical_hits(prediction, hits)

        # after removal of identical hits
        assert_equal(1, hits.length)
        assert_in_delta(90, hits[0].hsp_list[0].pidentity, 0.01)
        FileUtils.rm_rf("#{filename_fasta}.html")
      end

      it 'should remove identical matches among nucleotide sequences with tabular input' do
        output = File.open(ncbi_mrna_tab20, 'rb').read

        FileUtils.rm_rf("#{filename_fasta}.html") rescue Error

        default_opt = {
          input_fasta_file: filename_fasta,
          validations: ['all'],
          db: 'swissprot -remote',
          num_threads: 1
        }
        tabular_headers = 'qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore'

        b = GeneValidator::Validation.new(default_opt) # just use a valida filename to create the object

        prediction = Sequence.new
        prediction.length_protein = 219 / 3
        iterator_tab = TabularParser.new(ncbi_mrna_tab20, tabular_headers, :nucleotide)
        hits = iterator_tab.parse_next

        assert_equal(20, hits.length)

        hits = b.remove_identical_hits(prediction, hits)

        assert_equal(13, hits.length)
        assert_in_delta(98.61, hits[0].hsp_list[0].pidentity, 0.01)
        FileUtils.rm_rf("#{filename_fasta}.html")
      end

      it 'should remove identical matches among nucleotide sequences with xml input' do
        output = File.open(ncbi_mrna_xml20, 'rb').read

        FileUtils.rm_rf("#{filename_fasta}.html") rescue Error

        # just use a valid opts hash to create the object
        default_opt = {
          input_fasta_file: filename_fasta,
          validations: ['all'],
          db: 'swissprot -remote',
          num_threads: 1
        }

        b = GeneValidator::Validation.new(default_opt) 

        prediction = Sequence.new
        prediction.length_protein = 219 / 3

        iterator = Bio::BlastXMLParser::NokogiriBlastXml.new(output).to_enum
        hits = BlastUtils.parse_next_query_xml(iterator, :protein)

        assert_equal(20, hits.length)

        hits = b.remove_identical_hits(prediction, hits)

        assert_equal(13, hits.length)
        assert_in_delta(98.61, hits[0].hsp_list[0].pidentity, 0.01)
        FileUtils.rm_rf("#{filename_fasta}.html")
      end

      it 'should return error when using a nonexisting input file' do
        error = false
        begin
          default_opt = {
            input_fasta_file: 'test/test_files/not_existing.txt',
            validations: ['all'],
            db: 'swissprot -remote',
            num_threads: 1
          }

          (GeneValidator::Validation.new(default_opt)).run
        rescue SystemExit => error
          error = true
        end
        assert_equal(true, error)
      end
    end
  end
end
