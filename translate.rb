#!/usr/bin/env ruby

require "rubygems"
gem 'grosser-pomo', '>=0.5.1'
gem 'sishen-rtranslate'
require 'pomo'
require 'ruby-debug'
require 'rtranslate'

def load(filename)
end


def detect_locale(filename)
  locale = File.basename(File.dirname(filename))
  return nil unless locale =~ /^[a-z]{2}([-_][a-z]{2})?$/i
  locale
end

def translate(text, locale)
  begin
    Translate::RTranslate.translate(text, "en", locale)
  rescue
    nil
  end
end

def remove_comments(msgid)
  comment, text = msgid.split("|", 2)
  text || comment
end

def try_transalte(text, locale)
  # replace variables and eols
  subs = text.scan(/(%\{\S+\})/).flatten
  text_original = text.dup
  subs.each  {|s| text.sub!(s, "$$$$$$")}
  if trans = translate(text.gsub("\\n", "####"), locale)
    subs.each {|s| trans.sub!("$$$$$$", s)}
    trans.gsub("####", "\\n")
  else
    nil
  end
end

puts "Reading #{ARGV[0]}"
unless locale = detect_locale(ARGV[0])
  puts "Cannot detect locale, pass full file path"
  exit
end

puts "detected locale: #{locale}"
File.open(ARGV[0]) do |file|
  
  po_file = file.read
  po = Pomo::PoFile.parse(po_file)
  po.each do |t|
    next if t.msgid.empty?
    next unless t.msgstr.empty?
    trans = try_transalte(remove_comments(t.msgid), locale)
    next unless trans && trans.downcase != remove_comments(t.msgid).downcase
    t.msgstr = try_transalte(remove_comments(t.msgid), locale)
    puts "#{p.msgid} => #{p.msgstr}"
  end

  File.open(ARGV[0] + ".new", "w") {|f| f.write Pomo::PoFile.to_text(po.sort_by{|x| [*x.msgid].first || ""})}
end