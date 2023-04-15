# frozen_string_literal: true

require 'net/http'
require 'simple_oauth'
require 'uri'
require_relative 'errors'
require_relative 'endpoints/manage_tweets_v2'
require_relative 'endpoints/media_v1'

module Anzu
  class Client
    attr_accessor :access_token, :access_token_secret, :consumer_key, :consumer_secret, :bearer_token

    def initialize(access_token: nil, access_token_secret: nil, consumer_key: nil, consumer_secret: nil, bearer_token: nil)
      @access_token = access_token
      @access_token_secret = access_token_secret
      @consumer_key = consumer_key
      @consumer_secret = consumer_secret
      @bearer_token = bearer_token

      yield(self) if block_given?
    end

    def req_bearer(method, url)
      uri = URI.parse(url)

      req_klass = Net::HTTP.const_get(method.capitalize)
      req = req_klass.new(uri)

      req['authorization'] = "Bearer #{@bearer_token}"
      yield(req) if block_given?

      Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') do |http|
        http.request(req)
      end
    end

    def req_oauth1(method, url)
      uri = URI.parse(url)

      req_klass = Net::HTTP.const_get(method.to_s.capitalize)
      req = req_klass.new(uri)

      req['authorization'] =
        SimpleOAuth::Header.new(method, url, {}, consumer_key: @consumer_key, consumer_secret: @consumer_secret, token: @access_token, token_secret: @access_token_secret).to_s
      yield(req) if block_given?

      Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') do |http|
        http.request(req)
      end
    end
  end
end
