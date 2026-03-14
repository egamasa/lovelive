require 'json'
require 'time'

source_files = Dir.glob('source/*.json')
source_posts = []
source_files.each { |file| source_posts.concat(JSON.parse(File.read(file))) }

source_posts.sort_by! { |post| post['id_str'] }

grouped_posts =
  source_posts.group_by do |post|
    utc_time = Time.parse(post['created_at'])
    jst_time = utc_time.getlocal('+09:00')
    jst_time.strftime('%Y-%m')
  end

grouped_posts.each do |year_month, posts|
  output_file = "#{year_month}.jsonl"
  File.open(output_file, 'w') { |file| posts.each { |post| file.puts(JSON.generate(post)) } }

  puts "#{year_month} | #{posts.count} Posts"
end
