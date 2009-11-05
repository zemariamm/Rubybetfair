=begin
dirs = ["base","market","events","bets"]
THIS_DIR = File.expand_path(File.dirname(__FILE__))
# puts THIS_DIR
dirs.collect! { |d| THIS_DIR + "/#{d}" }
dirs.each do |d|
  # enter directory
  Dir.chdir(d)
  # gets all files
  files = Dir.entries(".")
  files = files.find_all { |f| (f =~ /\S*.rb$/) != nil }
  
  files.each do |f|
    puts "#{d}/#{f}"
    require "#{d}/#{f}"
  end
  # back to old dir
  Dir.chdir(THIS_DIR)
end
=end
