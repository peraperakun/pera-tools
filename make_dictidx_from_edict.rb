# encoding: utf-8
require 'mojinizer'

edict = ARGV.length > 0 ? ARGV[0] : "dict.dat"
output_index = ARGV.length > 1 ? ARGV[1] : "dict.idx"

file_position = 0
dict_index = {}
puts "Starting to process JMDict file..."
File.open(edict, "r:UTF-8").each_line do |line|
  if /(\S+)\s+\[(\S+)\]/ =~ line
    entry = $1
    reading = $2.hiragana
    dict_index[entry] = dict_index[entry] ? dict_index[entry] + ",#{file_position}" : "#{file_position}"
    dict_index[reading] = dict_index[reading] ? dict_index[reading] + ",#{file_position}" : "#{file_position}"
  elsif /(\S+)\s/ =~ line
    entry = $1.hiragana
    dict_index[entry] = dict_index[entry] ? dict_index[entry] + ",#{file_position}" : "#{file_position}"
  end
  file_position += line.length
end

puts "Outputting index..."
File.open(output_index, 'w:UTF-8') do |output|
  dict_index.each do |entry, file_positions|
    output.puts "#{entry},#{file_positions}"
  end
end
puts "...done"