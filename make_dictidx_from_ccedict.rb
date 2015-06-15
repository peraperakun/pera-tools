# encoding: utf-8

cedict = ARGV.length > 0 ? ARGV[0] : "cedict_ts.u8"
output_index = ARGV.length > 1 ? ARGV[1] : "dict.idx"

file_position = 0
dict_index = {}
puts "Starting to process cedict file..."
File.open(output_index, 'w:UTF-8') do |output|
  File.open(cedict, "r:UTF-8").each_line do |line|
    if line.start_with? "#"
      file_position += line.length
      next
    end

    if /^(\S+)\s+(\S+)\s/ =~ line
      trad = $1
      simp = $2
      output.puts "#{trad},#{simp};#{file_position}"
    end
    file_position += line.length
  end
end

puts "...done"