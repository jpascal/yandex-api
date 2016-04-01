require 'net/http'
require 'net/https'
require 'json'
require 'yaml'
require 'uri'
require 'cgi'

module Yandex
  module API
    module Translate
      URL_API = 'https://translate.yandex.net/'.freeze

      def self.configuration
        if defined? @environment
          raise "not configured Yandex.Translate for #{@environment} enviroment" unless @configuration
        else
          raise 'not configured Yandex.Translate' unless @configuration
        end
        @configuration
      end

      def self.load(file, env = nil)
        @environment = env.to_s if env
        config = YAML.load_file(file)
        @configuration = defined?(@environment) ? config[@environment] : config
      end

      def self.parse_json(json)
        return JSON.parse(json)
      rescue => e
        raise "#{e.message} in response"
      end

      def self.connection
        return @connection if defined? @connection
        uri = URI.parse(URL_API)
        @connection = Net::HTTP.new(uri.host, uri.port)
        if uri.scheme == 'https'
          @connection.use_ssl = true
          @connection.verify_mode = OpenSSL::SSL::VERIFY_NONE
        end
        @connection
      end

      def self.request(path, params = {})
        puts "\t\033[32mYandex.Translate:\033[0m #{params}" if configuration['verbose']
        query = params.merge!(
          key: configuration['token'],
          ui: configuration['ui']
        ).collect { |key, value| "#{key}=#{CGI.escape(value.to_s)}" }.join('&')

        response = connection.send(:get, [File.join('/api/v1.5/tr.json', path.to_s), query].join('?'))

        json = Direct.parse_json(response.body)

        raise "#{json['code']} - #{json['message']}" if json.key?('code') && json.key?('message')
        json
      end

      def self.languages
        request(:getLangs)
      end

      def self.detect(text)
        result = request(:detect, text: text)
        return result['lang'] if result.include?('lang')
        raise "#{json['code']} - Can't detect language"
      end

      def self.do(text, lang, options = {})
        request(
          :translate,
          options.merge(
            text: text,
            lang: lang
          )
        )
      end
    end
  end
end
