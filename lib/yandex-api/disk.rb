require 'time'
module Yandex
  module API
    module Disk
      URL_API = 'https://cloud-api.yandex.net/v1/disk'.freeze

      def self.configuration
        if defined? @environment
          raise "not configured Yandex.Disk for #{@environment} enviroment" unless @configuration
        else
          raise 'not configured Yandex.Disk' unless @configuration
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

      def self.request(method, path)
        headers = {
          'Authorization' => "OAuth #{configuration['token']}",
          'Content-Type' => 'application/json'
        }
        response = case method.to_sym
                   when :put, :post then connection.send(method.to_sym, path, nil, headers)
                   when :delete, :get then connection.send(method.to_sym, path, headers)
                   end
        json = parse_json(response.body || '{}')
        return json if [Net::HTTPNoContent, Net::HTTPOK, Net::HTTPCreated].include? response.class
        raise json['description'].to_s
      end

      def self.upload(stream, filename, url)
        uri = URI.parse(url)
        connection = Net::HTTP.new(uri.host, uri.port)
        if uri.scheme == 'https'
          connection.use_ssl = true
          connection.verify_mode = OpenSSL::SSL::VERIFY_NONE
        end
        request = Net::HTTP::Post.new uri
        boundary = "RubyClient#{rand(999_999)}"
        body = []
        body << "------#{boundary}"
        body << "Content-Disposition: form-data; name=\"file\"; filename=\"#{filename}\""
        body << 'Content-Type: text/plain'
        body << ''
        body << stream.read
        body << "------#{boundary}--"
        request.body = body.join("\r\n")
        request.content_type = "multipart/form-data; boundary=----#{boundary}"
        response = connection.request(request)
        raise response.body.to_s unless response.is_a?(Net::HTTPCreated)
        true
      end

      class BaseStruct < Struct
        def initialize(hash = {})
          hash.each do |key, value|
            next unless respond_to?("#{key}=")
            if value =~ /\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\+\d{2}:\d{2}/
              send("#{key}=", Time.parse(value))
            else
              send("#{key}=", value)
            end
          end
        end
      end

      class Object < BaseStruct.new(:name, :size, :created, :modified, :mime_type, :md5, :media_type, :path)
      end

      class Folder < BaseStruct.new(:name, :path, :modified, :created)
      end

      class Storage < BaseStruct.new(:trash_size, :total_space, :used_space)
        def initialize
          super Disk.request(:get, '/v1/disk/')
        end

        class << self
          def ls(path)
            response = Disk.request(:get, "/v1/disk/resources?path=#{path}")['_embedded'] || {}
            response['items'] ||= []
            response['items'].collect do |item|
              case item['type']
              when 'dir' then
                Disk::Folder.new(item)
              when 'file' then
                Disk::Object.new(item)
              end
            end
          end

          def exists?(path)
            Disk.request :get, "/v1/disk/resources?path=#{path}"
          end

          def mkdir!(path)
            Disk.request :put, "/v1/disk/resources?path=#{path}"
            true
          end

          def mkdir(path)
            mkdir!(path)
          rescue
            false
          end

          def rm!(path)
            Disk.request :delete, "/v1/disk/resources?path=#{path}"
            true
          end

          def rm(path)
            rm!(path)
          rescue
            false
          end

          def copy!(from, to)
            Disk.request :post, "/v1/disk/resources/copy?from=#{from}&path=#{to}"
            true
          end

          def copy(from, to)
            copy!(from, to)
          rescue
            false
          end

          def move!(from, to)
            Disk.request :post, "/v1/disk/resources/move?from=#{from}&path=#{to}"
            true
          end

          def move(from, to)
            move!(from, to)
          rescue
            false
          end

          def write!(file, to)
            params = Disk.request :get, "/v1/disk/resources/upload?path=#{to}"
            Disk.upload(file, to.split('/').last, params['href'])
            true
          end

          def write(file, to)
            write!(file, to)
          rescue
            false
          end

          def clean!(path = nil)
            if path.nil?
              Disk.request :delete, '/v1/disk/trash/resources'
            else
              Disk.request :delete, "/v1/disk/trash/resources?path=#{path}"
            end
            true
          end

          def clean(path = nil)
            clean!(path)
          rescue
            false
          end

          def restore!(path, to = path)
            Disk.request :put, "/v1/disk/trash/resources/restore?path=#{to}&name=#{path}"
            true
          end

          def restore(path, to = path)
            restore!(path, to)
          rescue
            false
          end
        end
      end
    end
  end
end
