require 'aws-sdk-s3'
require 'aws-sdk-sns'
require 'date'
require 'json'
require 'logger'
require 'net/http'
require 'rexml/document'
require 'time'

def send_sns_notification(status, message, logger)
  return unless ENV['SNS_TOPIC_ARN']

  message[:service] = 'IkizulivePostsSave'
  message[:status] = status

  sns = Aws::SNS::Client.new
  sns.publish(topic_arn: ENV['SNS_TOPIC_ARN'], message: message.to_json)
  logger.info("SNS notification sent: #{status}")
rescue => e
  logger.warn("SNS notification failed: #{e.message}")
end

def main(event, logger)
  # 日付指定（eventから取得、なければ前日）
  target_date =
    event['date'] ? Date.parse(event['date']) : (Time.now.getlocal('+09:00').to_date - 1)
  logger.info("Target date: #{target_date}")

  # RSSフィード取得
  feed_url = ENV['RSS_FEED_URL']
  logger.info("Fetching RSS feed from: #{feed_url}")

  uri = URI(feed_url)
  response = Net::HTTP.get_response(uri)

  unless response.is_a?(Net::HTTPSuccess)
    raise "HTTP request failed: #{response.code} #{response.message}"
  end

  xml_data = response.body
  logger.info("Successfully fetched XML data: #{xml_data.length} bytes")

  # 対象期間設定
  target_start = Time.new(target_date.year, target_date.month, target_date.day, 0, 0, 0, '+09:00')
  target_end = target_start + 86_400

  doc = REXML::Document.new(xml_data)
  items = []
  processed_count = 0
  filtered_count = 0

  # ポスト抽出
  doc
    .elements
    .each('rss/channel/item') do |item|
      processed_count += 1

      pub_date_str = item.elements['pubDate']&.text
      next unless pub_date_str

      begin
        pub_date = Time.parse(pub_date_str).getlocal('+09:00')

        if pub_date >= target_start && pub_date < target_end
          filtered_count += 1

          item_data = {}
          item.elements.each do |element|
            item_data[element.name] = element.text unless %w[title guid category].include?(
              element.name
            )
          end
          items << item_data
        end
      rescue => e
        logger.warn("Error processing item: #{e.message}")
        next
      end
    end

  logger.info(
    "Processing completed: #{processed_count} items processed, #{filtered_count} items matched date filter, #{items.length} items added"
  )

  # JSON出力・S3アップロード
  unless items.empty?
    json_filename = "#{target_date.strftime('%Y-%m-%d')}.json"
    json_data = JSON.pretty_generate(items)

    s3_bucket = ENV['S3_BUCKET']
    s3_path = ENV['S3_PATH']
    s3_key = "#{s3_path}/#{target_date.strftime('%Y-%m')}/#{json_filename}"
    s3 = Aws::S3::Client.new
    s3.put_object(
      bucket: s3_bucket,
      key: "#{s3_path}/#{target_date.strftime('%Y-%m')}/#{json_filename}",
      body: json_data,
      content_type: 'application/json'
    )
    logger.info("JSON uploaded to S3: s3://#{s3_bucket}/#{s3_key}")
  end

  # Amazon SNS 完了通知
  message = {
    fields: [
      { name: 'Date', value: target_date.strftime('%Y-%m-%d'), inline: true },
      { name: 'Posts count', value: filtered_count, inline: true }
    ]
  }
  unless items.empty?
    message[:fields] << { name: 'File', value: "s3://#{s3_bucket}/#{s3_key}", inline: false }
  else
    message[:fields] << { name: 'File', value: 'No file saved.', inline: false }
  end
  send_sns_notification('OK', message, logger)
end

def lambda_handler(event:, context:)
  logger = Logger.new(STDOUT)
  logger.level = Logger::INFO

  begin
    main(event, logger)
  rescue => e
    logger.error("Lambda execution failed: #{e.message}")

    # Amazon SNS エラー通知
    error_message = { message: e.message }
    send_sns_notification('ERROR', error_message, logger)
    raise e
  end
end
