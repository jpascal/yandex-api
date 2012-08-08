require 'net/http'
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
          :token => configuration["token"],
          :method => method
        }
        
        body.merge!({:param => params}) unless params.empty?
        url = URI.parse(URL_API)

        if configuration["debug"]
          puts "\t\033[32mURL: \033[0m#{URL_API}"
          puts "\t\033[32mMethod: \033[0m#{method}"
          puts "\t\033[32mParams: \033[0m#{params.inspect}"  
        end

        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        response = http.post(url.path,JSON.generate(body))

        raise Yandex::API::RuntimeError.new("#{response.code} - #{response.message}") unless response.code.to_i == 200

        json = {}
        
        begin
          json = JSON.parse(response.body)
        rescue => e
          raise RuntimeError.new "#{e.message} in response"
        end

        if json.has_key?("error_code")
          code = json["error_code"].to_i
          error = json.has_key?("error_detail") ? json["error_detail"] : json["error_str"]
          raise RuntimeError.new "#{code} - #{error}"
        end
        
        return json["data"]
      end
    end
  end
end
