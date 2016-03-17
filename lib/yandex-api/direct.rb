require 'net/http'
require 'net/https'
require 'json'
require 'yaml'
require 'uri'

module Yandex
  module API
    module Direct
      URL_API = 'https://api.direct.yandex.ru/v4/json/'.freeze
      URL_API_SANDBOX = 'https://api-sandbox.direct.yandex.ru/v4/json/'.freeze

      def self.configuration
        if defined? @environment
          raise "not configured Yandex.Direct for #{@environment} enviroment" unless @configuration
        else
          raise 'not configured Yandex.Direct' unless @configuration
        end
        @configuration
      end

      def self.parse_json(json)
        return JSON.parse(json)
      rescue => e
        raise "#{e.message} in response"
      end

      def self.load(file, env = nil)
        @environment = env.to_s if env
        config = YAML.load_file(file)
        @configuration = defined?(@environment) ? config[@environment] : config
        @configuration['sandbox'] ||= false
      end

      def self.request(method, params = {})
        body = {
          locale: configuration['locale'],
          token: configuration['token'],
          method: method
        }

        body[:param] = if body[:method] == 'GetCampaignsList'
                         [configuration['login']]
                       else
                         params
                       end

        url = URI(configuration['sandbox'] ? URL_API_SANDBOX : URL_API)

        puts "\t\033[32mYandex.Direct:\033[0m #{method}(#{body[:param]})" if configuration['verbose']

        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        response = http.post(url.path, JSON.generate(body))

        raise "#{response.code} - #{response.message}" unless response.code.to_i == 200

        json = Direct.parse_json(response.body)

        if json.key?('error_code') && json.key?('error_str')
          code = json['error_code'].to_i
          error = json['error_detail'].empty? ? json['error_str'] : json['error_detail']
          raise "#{code} - #{error}"
        end

        json['data']
      end
    end
  end
end
