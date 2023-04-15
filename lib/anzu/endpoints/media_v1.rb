# frozen_string_literal: true

require 'mime/types'
require 'json'
require 'uri'

module Anzu
  class Client
    UPLAOD_MEDIA_SEGMENT_SIZE = 5_000_000

    # Upload media (chunked)
    # https://developer.twitter.com/en/docs/twitter-api/v1/media/upload-media/uploading-media/chunked-media-upload
    # @param [String | File] bin
    # @param [String | nil] mime_type
    # @param [String | nil] media_category Must be nil, tweet_image, tweet_video, tweet_gif, dm_image, dm_video, dm_gif, or subtitles
    # @param [Array<String>] additional_owners
    def upload_media_v1(bin, mime_type = nil, media_category: nil, additional_owners: nil)
      unless mime_type
        file = bin.is_a?(String) ? File.open(bin, 'rb') : bin
        file.binmode
        file.rewind
        bin = file.read
        mime_type ||= MIME::Types.type_for(file.path).find {|e| e.media_type == 'image' || e.media_type == 'video'}&.content_type
      end

      unless media_category
        if mime_type == 'image/gif'
          media_category = 'tweet_gif'
        elsif mime_type == 'application/x-subrip'
          media_category = 'subtitles'
        elsif mime_type.start_with?('image/')
          media_category = 'tweet_image'
        elsif mime_type.start_with?('video/')
          media_category = 'tweet_video'
        end
      end

      bytesize = bin.bytesize

      init_res = req_oauth1(:post, 'https://upload.twitter.com/1.1/media/upload.json') do |req|
        req.set_form(
          [
            %w[command INIT],
            ['total_bytes', bytesize.to_s],
            ['media_type', mime_type],
            media_category && ['media_category', media_category],
            additional_owners && ['additional_owners', additional_owners.join(',')]
          ].compact,
          'multipart/form-data'
        )
        puts req.body
      end
      Error.raise_from_response(init_res)
      init_json = JSON.parse(init_res.body)

      count = (bytesize + UPLAOD_MEDIA_SEGMENT_SIZE - 1) / UPLAOD_MEDIA_SEGMENT_SIZE
      count.times do |i|
        append_res = req_oauth1(:post, 'https://upload.twitter.com/1.1/media/upload.json') do |req|
          req.set_form(
            [
              %w[command APPEND],
              ['media_id', init_json['media_id_string']],
              ['media', bin.byteslice(i * UPLAOD_MEDIA_SEGMENT_SIZE, UPLAOD_MEDIA_SEGMENT_SIZE), { content_type: 'application/octet-stream' }],
              ['segment_index', i.to_s]
            ],
            'multipart/form-data'
          )
        end
        Error.raise_from_response(append_res)
      end

      finalize_res = req_oauth1(:post, 'https://upload.twitter.com/1.1/media/upload.json') do |req|
        req.set_form([%w[command FINALIZE], ['media_id', init_json['media_id_string']]], 'multipart/form-data')
      end
      Error.raise_from_response(finalize_res)

      json = JSON.parse(finalize_res.body)

      if json['processing_info'] && json['processing_info']['state'] == 'pending'
        sleep json['processing_info']['check_after_secs']

        loop do
          status_res = req_oauth1(:get, "https://upload.twitter.com/1.1/media/upload.json?command=STATUS&media_id=#{URI.encode_www_form_component(json['media_id_string'])}")
          Error.raise_from_response(status_res)
          status_json = JSON.parse(status_res.body)

          case status_json['processing_info']['state']
          when 'succeeded'
            break
          when 'failed'
            raise MediaUploadError.new(status_json['processing_info']['error']['code'], status_json['processing_info']['error']['name'],
                                       status_json['processing_info']['error']['message'])
          when 'pending'
            sleep status_json['processing_info']['check_after_secs']
          end
        end
      end

      {
        media_id: json['media_id_string'],
        expires_after_secs: json['expires_after_secs'],
        size: json['size']
      }
    end
  end
end
