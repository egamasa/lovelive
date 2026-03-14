require 'json'

source_files = Dir.glob('source/missing_posts/*.json')
source_posts = source_files.map { |file| JSON.parse(File.read(file)) }

output_file = 'missing_posts.jsonl'
File.open(output_file, 'w') do |file|
  source_posts.each do |post|
    sliced_post = {
      '__typename' => post.dig('raw_data', '__typename'),
      'lang' => post.dig('raw_data', 'legacy', 'lang'),
      'favorite_count' => post.dig('raw_data', 'legacy', 'favorite_count'),
      'created_at' => post['created_at'].sub('Z', '.000Z'),
      'display_text_range' => post.dig('raw_data', 'legacy', 'display_text_range'),
      'entities' => post.dig('raw_data', 'legacy', 'entities')&.except('timestamps'),
      'id_str' => post.dig('raw_data', 'legacy', 'id_str'),
      'text' => post.dig('raw_data', 'legacy', 'full_text'),
      'user' => {
        'id_str' => post.dig('raw_data', 'legacy', 'user_id_str'),
        'name' => post.dig('raw_data', 'core', 'user_results', 'result', 'core', 'name'),
        'screen_name' =>
          post.dig('raw_data', 'core', 'user_results', 'result', 'core', 'screen_name'),
        'is_blue_verified' =>
          post.dig('raw_data', 'core', 'user_results', 'result', 'is_blue_verified'),
        'profile_image_shape' =>
          post.dig('raw_data', 'core', 'user_results', 'result', 'profile_image_shape'),
        'verified' =>
          post.dig('raw_data', 'core', 'user_results', 'result', 'verification', 'verified'),
        'profile_image_url_https' =>
          post.dig('raw_data', 'core', 'user_results', 'result', 'avatar', 'image_url')
      },
      'edit_control' => post.dig('raw_data', 'edit_control'),
      'conversation_count' => 0,
      'news_action_type' => 'conversation',
      'isEdited' => false,
      'isStaleEdit' => false
    }

    file.puts(JSON.generate(sliced_post))
  end
end
