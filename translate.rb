#!/usr/bin/env ruby

require "rubygems"
gem 'grosser-pomo', '>=0.5.1'
require 'pomo'


def load(filename)
end


def detect_locale(filename)
  locale = filename.dirname.basename.to_s
  return nil unless locale =~ /^[a-z]{2}([-_][a-z]{2})?$/i
  locale
end

puts "Reading #{ARGV[0]}"
unless locale = detect_locale(ARGV[0])
  puts "Cannot detect locale, pass full file path"
  exit
end