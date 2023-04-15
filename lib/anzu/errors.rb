# frozen_string_literal: true

module Anzu
  class Error < StandardError
    def self.raise_from_response(response)
      response.value
    rescue StandardError
      begin
        json = JSON.parse(response.body)
        raise Error, json['error']
      rescue StandardError
        raise Error, response.body
      end
    end
  end

  class MediaUploadError < StandardError
    def initialize(code, name, message)
      @code = code
      @name = name
      @message = message
      super("#{code}: #{name} - #{message}")
    end
  end
end
