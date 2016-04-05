require 'active_support/inflector'
require 'active_support/hash_with_indifferent_access'
require 'active_model'
require 'active_model/serializers/json'
require 'faraday'

module Yandex::API::Direct

  class Error < RuntimeError
    attr_accessor :request_id, :code, :message, :detail
    def initialize(request_id, code, message, detail)
      self.request_id = request_id
      self.code = code
      self.message = message
      self.detail = detail
    end
    def to_s
      "#{self.message} (#{self.code})"
    end
  end

  SERVICE = 'https://api.direct.yandex.com/json/v5'

  class Bid
    def self.attr_accessor(*args)
      @attributes = *args
      super(*args)
    end
    def self.attributes
      @attributes
    end

    include ActiveModel::Model
    include ActiveModel::Serialization
    attr_accessor :KeywordId, :Bid, :ContextBid
  end

  def self.decode(json)
    result = []
    JSON.parse!(json)['result'].map do |object, objects|
      object = "Yandex::API::Direct::#{object.singularize.camelize}".constantize
      objects.map do |params|
        result << object.new(params)
      end
    end
    result
  end

  def self.encode(object)
    object.to_json
  end

  def self.namespace(object)
    object.name.demodulize.pluralize.downcase
  end

  def self.selection(conditions = nil, *fields)
    {
        'SelectionCriteria' => (conditions.nil? ? {} : conditions),
        'FieldNames' => (fields.nil? ? [] : Array(fields).flatten.uniq)
    }
  end

  def self.request(method, namespace, params = nil)
    connection = Faraday.new(url: SERVICE) do |faraday|
      faraday.adapter  Faraday.default_adapter
    end
    response = connection.post(namespace, {
        'method' => method,
        'params' => params || {}
    }.to_json, {
        'Authorization' => 'Bearer asdasdasdasd',
        'Client-Login' => 'agrom',
        'Accept-Language' => 'ru',
        'Content-Type' => 'application/json; charset=utf-8'
    })

    response = JSON.parse!(response.body)

    if (error = response['error'])
      raise Error.new(error['request_id'], error['error_code'], error['error_string'], error['error_detail'])
    end

    response
  end

  class Base
    def self.attributes
      @attributes || []
    end

    def self.direct_attributes(*args)
      @attributes ||= []
      args.map do |arg|
        class_eval("def #{arg};@#{arg};end")
        class_eval("def #{arg}=(val);@#{arg}=val;end")
        @attributes << arg
      end
    end

    def self.objects
      @objects || []
    end

    def self.direct_objects(options)
      @objects ||= []
      options.map do |name, type|
        class_eval("def #{name};@#{name};end")
        class_eval("def #{name}=(val);@#{name}=val;end")
        @objects << [name, type]
      end
    end

    def self.arrays
      @arrays || []
    end

    def self.direct_arrays(options)
      @arrays ||= []
      options.map do |name, type|
        class_eval("def #{name};@#{name};end")
        class_eval("def #{name}=(val);@#{name}=val;end")
        @arrays << [name, type]
      end
    end

    def to_hash
      hash = {}
      # build hash of attributes
      self.class.attributes.each do |attribute|
        value = self.send(attribute)
        next if value.nil?
        hash[attribute] = value
      end
      # build hash of arrays
      self.class.arrays.each do |array, _type|
        data_array = self.send(array) || []
        next if data_array.empty?
        hash[array] = []
        data_array.each do |data|
          hash[array] << data.to_hash
        end
      end
      # build hash of objects
      self.class.objects.each do |name, _|
        object = self.send(name)
        next if object.nil?
        value_hash = send(name).to_hash || {}
        next if value_hash.empty?
        hash[name] = value_hash
      end
      hash
    end

    def initialize(params = {})
      params.each do |key, value|
        object = self.class.objects.find { |s| s.first.to_sym == key.to_sym }
        array = self.class.arrays.find { |s| s.first.to_sym == key.to_sym }
        if object
          send("#{key}=", object.last.new(value))
        elsif array
          send("#{key}=", value.collect { |element| array.last.new(element) })
        elsif respond_to?("#{key}=")
          send("#{key}=", value)
        end
      end
    end
  end
end
