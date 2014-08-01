require 'net/http'
require 'net/https'
require 'json'
require 'yaml'
require 'uri'
require 'cgi'

module Yandex
  module API
    module Translate
      URL_API = 'https://translate.yandex.net/'

      def self.configuration
        if defined? @environment
          raise RuntimeError.new("not configured Yandex.Translate for #{@environment} enviroment") unless @configuration
        else
          raise RuntimeError.new('not configured Yandex.Translate') unless @configuration
        end
        @configuration
      end

      def self.load file, env = nil
        @environment = env if env
        config = YAML.load_file(file)
        @configuration = defined?(@environment) ? config[@environment] : config
      end

      def self.parse_json json
        begin
          return JSON.parse(json)
        rescue => e
          raise RuntimeError.new "#{e.message} in response"
        end
      end

      def self.connection
        return @connection if defined? @connection
        uri = URI.parse(URL_API)
        @connection = Net::HTTP.new(uri.host, uri.port)
        if uri.scheme == "https"
          @connection.use_ssl = true
          @connection.verify_mode = OpenSSL::SSL::VERIFY_NONE
        end
        return @connection
      end

      def self.request path, params = {}

        if configuration['verbose']
          puts "\t\033[32mURL: \033[0m#{URL_API}"
          puts "\t\033[32mMethod: \033[0m#{path}"
          puts "\t\033[32mParams: \033[0m#{params.inspect}"
        end

        query = (
          params.merge!({
            :key => configuration['token'],
            :ui => configuration['ui']
          })
        ).collect {|key,value| "#{key.to_s}=#{CGI.escape(value)}" }.join("&")

        response = connection.send(:get,[File.join('/api/v1.5/tr.json',path.to_s),query].join("?"))

        json = Direct.parse_json(response.body)

        if json.has_key?('code') and json.has_key?('message')
          raise RuntimeError.new "#{json['code']} - #{json['message']}"
        end
        return json
      end

      def self.languages
        request(:getLangs)
      end

      def self.detect(text)
        result = request(:detect, :text => text)
        if result.include? 'lang'
          return result['lang']
        else
          raise RuntimeError.new "#{json['code']} - Can't detect language"
        end
      end

      def self.do(text, lang, options = {})
        result = request(:translate, options.merge({
          :text => text,
          :lang => lang
        }))
      end
    end
  end
end
