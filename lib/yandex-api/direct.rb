require 'net/http'
require 'net/https'
require 'json'
require 'yaml'
require 'uri'

module Yandex
  module API
    module Direct
      URL_API = "https://soap.direct.yandex.ru/json-api/v4/"
      
      def self.configuration
        if defined? @enviroment
          raise RuntimeError.new("not configured Yandex.Direct for #{@enviroment} enviroment") unless @configuration
        else
          raise RuntimeError.new("not configured Yandex.Direct") unless @configuration
        end
        @configuration
      end

      def self.parse_json json
        begin
          return JSON.parse(json)
        rescue => e
          raise RuntimeError.new "#{e.message} in response"
        end
      end
      
      def self.load file, env = nil
        @enviroment = env if env
        config = YAML.load_file(file)
        @configuration = defined?(@enviroment) ? config[@enviroment] : config
      end

      def self.request method, params = {}

        body = {
          :locale => configuration["locale"],
          :login => configuration["login"],
          :application_id => configuration["application_id"],
          :token => configuration["application_token"],
          :method => method
        }
        
        body.merge!({:param => params}) unless params.empty?
        url = URI.parse(URL_API)

        if configuration["verbose"]
          puts "\t\033[32mURL: \033[0m#{URL_API}"
          puts "\t\033[32mMethod: \033[0m#{method}"
          puts "\t\033[32mParams: \033[0m#{params.inspect}"  
        end

        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        response = http.post(url.path,JSON.generate(body))

        raise Yandex::API::RuntimeError.new("#{response.code} - #{response.message}") unless response.code.to_i == 200

        json = Direct.parse_json(response.body)
        
        if json.has_key?("error_code") and json.has_key?("error_str")
          code = json["error_code"].to_i
          error = json["error_detail"].length > 0 ? json["error_detail"] : json["error_str"]
          raise RuntimeError.new "#{code} - #{error}"
        end
        
        return json["data"]
      end
    end
  end
end
