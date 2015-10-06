require_relative 'test_helper'
require 'genevalidator/ext/array'
require 'minitest/autorun'

module GeneValidator
  # Test the Enumerable extension class
  class TestArray < Minitest::Test
    describe 'Array Class' do
      it 'test1' do
        v = [1, 2, 3, 4, 5, 6]
        assert_equal(3.5, v.inject(:+).to_f / v.size)
        assert_equal(3.5, v.median)
        assert_equal(1.870829, v.standard_deviation.round(6))
      end
    end
  end
end
