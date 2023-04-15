# frozen_string_literal: true

require 'json'
require 'uri'

module Anzu
  class Client
    def create_tweet_v2(
      text,
      direct_message_deep_link: nil,
      for_super_followers_only: nil,
      geo_place_id: nil,
      media_ids: nil,
      media_tagged_user_ids: nil,
      poll_duration_minutes: nil,
      poll_options: nil,
      quote_tweet_id: nil,
      exclude_reply_user_ids: nil,
      in_reply_to_tweet_id: nil,
      reply_settings: nil
    )
      options = {
        direct_message_deep_link: direct_message_deep_link,
        for_super_followers_only: for_super_followers_only,
        geo: geo_place_id && { place_id: geo_place_id }.compact,
        media: media_ids && { media_ids: media_ids.map(&:to_s), tagged_user_ids: media_tagged_user_ids&.map(&:to_s) }.compact,
        poll: poll_options && { duration_minutes: poll_duration_minutes, options: poll_options }.compact,
        quote_tweet_id: quote_tweet_id,
        reply: in_reply_to_tweet_id && { in_reply_to_tweet_id: in_reply_to_tweet_id.to_s, exclude_reply_user_ids: exclude_reply_user_ids&.map(&:to_s) }.compact,
        reply_settings: reply_settings,
        text: text
      }
      options.compact!

      res = req_oauth1(:post, 'https://api.twitter.com/2/tweets') do |req|
        req.content_type = 'application/json; charset=UTF-8'
        req.body = options.to_json
      end
      Error.raise_from_response(res)

      json = JSON.parse(res.body)
      { id: json['data']['id'], text: json['data']['text'] }
    end

    def delete_tweet_v2(id)
      res = req_oauth1(:delete, "https://api.twitter.com/2/tweets/#{URI.encode_www_form_component(id.to_s)}")
      Error.raise_from_response(res)

      json = JSON.parse(res.body)
      { deleted: json['data']['deleted'] }
    end
  end
end
