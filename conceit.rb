require 'rubygems'
require 'sinatra'
require 'uri'

#TODO POST data should cat to STDIN
get /(.*)/ do
  parts = params[:captures].first.split('/')
  cmd_line = parts.find_all{|x| !x.empty?}.map{|x| URI.unescape(x).inspect }
  command = cmd_line.shift

  request.params.each do |key, value|
    if key.length == 1
      if value.nil?
        cmd_line.unshift " -#{key}"
      else
        cmd_line.unshift " -#{key} #{value.inspect}"
      end
    else
      if value.nil?
        cmd_line.unshift " --#{key}"
      else
        cmd_line.unshift " --#{key}=#{value.inspect}"
      end
    end
  end
  cmd_line.unshift command
  cmd_line = cmd_line.join(" ")

  STDERR.puts cmd_line

  output = `#{cmd_line} 2>&1`
  stat = $?.to_i
  content_type :txt
  if stat != 0
    status(500+stat)
  end
  output
end
