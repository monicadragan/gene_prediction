# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'genevalidator/version'

Gem::Specification.new do |s|
  # meta
  s.name        = 'GeneValidator'
  s.date        = '2013-07-22'
  s.version     =  GeneValidator::VERSION
  s.authors     = ['Monica Dragan', 'Ismail Moghul', 'Anurag Priyam', 'Yannick Wurm']
  s.email       = 'monica.dragan@cti.pub.ro'
  s.homepage    = 'https://github.com/monicadragan/GeneValidator'
  s.license     = 'GPL'
  s.summary     = 'Identifying problems with gene predictions.'
  s.description = <<DESC
The tool validates the input predicted genes and provides useful information (length validation, gene merge validation, sequence duplication checking, ORF finding) based on the similarities to genes in public databases.
DESC

  s.required_ruby_version     = '>= 1.9.3'
  s.add_development_dependency 'bundler', '~> 1.6'
  s.add_development_dependency 'rake', '~>10.3'
  s.add_dependency('bio', '~> 1.4')
  s.add_dependency('bio-blastxmlparser', '~>2.0')
  s.add_dependency('minitest', '~> 5.4')
  s.add_dependency('statsample', '~> 1.4')

  s.files         = `git ls-files -z`.split("\x0")
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ['lib']

  s.post_install_message = <<INFO

------------------------------------------------------------------------
  Thank you for validating your gene predictions with GeneValidator!

  To launch GeneValidator execute 'genevalidator' from command line.

    $ genevalidator [options] FASTA_FILE

  Visit https://github.com/monicadragan/GeneValidator for more information.
------------------------------------------------------------------------

INFO
end
