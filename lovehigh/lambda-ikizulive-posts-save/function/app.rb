require 'aws-sdk-s3'
require 'csv'
require 'date'
require 'json'
require 'logger'
require 'net/http'
require 'rexml/document'
require 'time'

def process_content(content, logger)
  return content if content.nil? || content.empty?

  # HTMLタグ変換
  transformations = [
    # rsshub-quoteクラスのdivをblockquoteに変換
    [/<div\s+class="rsshub-quote"[^>]*>/, '<blockquote>'],
    # blockquote直後の余分なbrタグを削除
    [%r{<blockquote>(\s*<br\s*/?\s*)+}, '<blockquote>'],
    # ユーザー名をciteタグで囲む
    [/<blockquote>([^<]+?):\s*/, '<blockquote><cite>\1</cite><br>'],
    # blockquote開始タグ直後の引用符を削除
    [/<blockquote>\s*"/, '<blockquote>'],
    # blockquote終了タグ直後の引用符を削除
    [%r{</blockquote>\s*"}, '</blockquote>'],
    # cite終了タグとbr間の余分な空白を削除
    [%r{</cite><br>\s+}, '</cite><br>']
  ]

  transformations.each { |pattern, replacement| content = content.gsub(pattern, replacement) }

  # blockquoteが含まれる場合の特別な処理
  if content.include?('<blockquote>')
    # </div>を</blockquote>に変換
    content = content.gsub(%r{</div>(?!.*</div>)}, '</blockquote>')

    # 最初の余分な"を削除
    content = content.sub(/^"/, '')

    # blockquote直後の不正な文字を修正
    content = content.gsub(/<blockquote>>/, '<blockquote>')

    # blockquote直後のbrタグを削除
    content = content.gsub(%r{<blockquote><br\s*/?>}, '<blockquote>')

    # blockquote内の処理を一括で行う
    content =
      content.gsub(%r{<blockquote>(.*?)</blockquote>}m) do |match|
        blockquote_content = $1

        # img削除と&ensp;削除
        blockquote_content = blockquote_content.gsub(%r{<img[^>]*/?>}i, '')
        blockquote_content = blockquote_content.sub(/&ensp;/, '')

        # ユーザー名をciteで囲む（コロンまでの部分）
        if blockquote_content.match(/^([^<]+?):\s*/)
          user_name = $1.strip
          rest_content = blockquote_content.sub(/^[^<]+?:\s*/, '')
          blockquote_content = "<cite>#{user_name}</cite><br>#{rest_content}"
        end

        # 最後のbr削除（改行文字や空白も含む）
        blockquote_content = blockquote_content.gsub(%r{\s*(<br\s*/?\s*>?\s*)+\s*$}, '')

        "<blockquote>#{blockquote_content}</blockquote>"
      end
  end

  return content
end

def process_posts(event, logger)
  # 日付指定（eventから取得、なければ前日）
  target_date = event['date'] ? Date.parse(event['date']) : Date.today - 1
  logger.info("Target date: #{target_date}")

  feed_url = ENV['RSS_FEED_URL']
  logger.info("Fetching RSS feed from: #{feed_url}")

  uri = URI(feed_url)
  response = Net::HTTP.get_response(uri)

  unless response.is_a?(Net::HTTPSuccess)
    raise "HTTP request failed: #{response.code} #{response.message}"
  end

  xml_data = response.body
  logger.info("Successfully fetched XML data: #{xml_data.length} bytes")

  target_start = Time.new(target_date.year, target_date.month, target_date.day, 0, 0, 0, '+09:00')
  target_end = target_start + 86_400

  doc = REXML::Document.new(xml_data)
  items = []
  processed_count = 0
  filtered_count = 0

  doc
    .elements
    .each('rss/channel/item') do |item|
      processed_count += 1

      description = item.elements['description']&.text
      link = item.elements['link']&.text
      pub_date_str = item.elements['pubDate']&.text

      next unless pub_date_str

      begin
        pub_date = Time.parse(pub_date_str).getlocal('+09:00')
        unix_time = pub_date.to_i

        if pub_date >= target_start && pub_date < target_end
          filtered_count += 1
          screen_name = link&.match(%r{(?:twitter\.com|x\.com)/([^/]+)/?})&.[](1)

          items << {
            screen_name: screen_name,
            content: process_content(description, logger),
            link: link,
            datetime: unix_time
          }
        end
      rescue => e
        logger.warn("Error processing item: #{e.message}")
        next
      end
    end

  logger.info(
    "Processing completed: #{processed_count} items processed, #{filtered_count} items matched date filter, #{items.length} items added"
  )

  # CSV出力とS3アップロード
  return if items.empty?

  csv_filename = "#{target_date.strftime('%Y-%m-%d')}.csv"
  csv_data =
    CSV.generate(encoding: 'UTF-8') do |csv|
      csv << %w[screen_name content link datetime]
      items.each do |item|
        csv << [item[:screen_name], item[:content], item[:link], item[:datetime]]
      end
    end

  s3_bucket = ENV['S3_BUCKET']
  s3_path = ENV['S3_PATH'] || 'ikizu-live'
  s3 = Aws::S3::Client.new
  s3.put_object(
    bucket: s3_bucket,
    key: "#{s3_path}/#{csv_filename}",
    body: csv_data,
    content_type: 'text/csv'
  )
  logger.info("CSV uploaded to S3: s3://#{s3_bucket}/#{s3_path}/#{csv_filename}")
end

def lambda_handler(event:, context:)
  logger = Logger.new(STDOUT)
  logger.level = Logger::INFO

  begin
    process_posts(event, logger)
  rescue => e
    logger.error("Lambda execution failed: #{e.message}")
  end
end
