require 'json'
require 'yaml'
require 'uri'
require 'faraday'

require 'active_support/inflector'
require 'active_support/hash_with_indifferent_access'
require 'active_model'
require 'active_model/serializers/json'

require_relative 'direct/error'
require_relative 'direct/selection_criteria'
require_relative 'direct/exception_notification'
require_relative 'direct/action_result'

require_relative 'direct/base'

require_relative 'direct/campaign'
require_relative 'direct/bid'

module Yandex
  module API
    module Direct
      URL_API = 'https://api.direct.yandex.com/json/v5'.freeze
      URL_API_SANDBOX = 'https://api-sandbox.direct.yandex.com/json/v5'.freeze

      def self.configuration
        if defined? @environment
          raise "not configured Yandex.Direct for #{@environment} enviroment" unless @configuration
        else
          raise 'not configured Yandex.Direct' unless @configuration
        end
        @configuration
      end

      def self.decode(object, response)
        response['result'][object.name.pluralize.demodulize].map{ |attributes| object.new(attributes) }
      end

      def self.encode(object)
        object.to_json
      end

      def self.load(file, env = nil)
        @environment = env.to_s if env
        config = YAML.load_file(file)
        @configuration = defined?(@environment) ? config[@environment] : config
        @configuration['sandbox'] ||= false
      end

      def self.request(method, path, params = nil)
        connection = Faraday.new(url: (configuration['sandbox'] ? URL_API_SANDBOX : URL_API)) do |faraday|
          faraday.adapter  Faraday.default_adapter
        end

        response = connection.post(path, {
           'method' => method,
           'params' => params.to_param || {}
        }.to_json, {
           'Authorization' => "Bearer #{configuration['token']}",
           'Client-Login' => configuration['login'],
           'Accept-Language' => configuration['locale'],
           'Content-Type' => 'application/json; charset=utf-8'
        })

        raise "Yandex.Direct response with status #{response.status}" unless response.success?

        response = JSON.parse(response.body)

        if (error = response['error'])
          raise Error.new(error['request_id'], error['error_code'], error['error_string'], error['error_detail'])
        end

        response['result']
      end
    end
  end
end
