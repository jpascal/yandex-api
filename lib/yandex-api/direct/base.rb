require 'active_support/inflector'
require 'active_support/hash_with_indifferent_access'
require 'active_model'
require 'active_model/serializers/json'
require 'faraday'

module Yandex::API::Direct

  class Error < RuntimeError
    attr_accessor :request_id, :code, :text, :detail
    def initialize(request_id, code, text, detail)
      self.request_id = request_id
      self.code = code
      self.text = text
      self.detail = detail
    end
    def message
      "#{self.text} (#{self.code}): #{self.detail}"
    end
  end

  SERVICE = 'https://api-sandbox.direct.yandex.com/json/v5'

  class Relation
  protected
    attr_accessor :selection_criteria, :field_names, :page_limit, :page_offset
  public
    attr_accessor :object
    def initialize(object)
      self.object = object
      self.field_names = object.attributes
    end
    def select(*field_names)
      self.field_names = Array(field_names)
      self
    end
    def limit(value)
      self.page_limit = value
      self
    end
    def offset(value)
      self.page_offset = value
      self
    end
    def where(criteria)
      (self.selection_criteria ||= {}).merge!(criteria)
      self
    end
    def get
      Yandex::API::Direct.decode(self.object, Yandex::API::Direct.request(:get, self.object.path, self.to_param))
    end
    def to_param
      params = {
          'SelectionCriteria' => (self.selection_criteria.nil? ? {} : self.selection_criteria),
          'FieldNames' => (self.field_names.nil? ? [] : Array(self.field_names).flatten.uniq)
      }
      params.merge!({'Page' => {'Offset' => self.page_offset}}) if self.page_offset
      params.merge!({'Page' => {'Limit' => self.page_limit}}) if self.page_limit
      params
    end
  end

  class Model
    include ActiveModel::Model
    include ActiveModel::Serialization
    class << self
      def attr_accessor(*args)
        @attributes = *args
        super(*args)
      end
      def attributes
        @attributes
      end
      delegate :select, :limit, :offset, :where, :get, to: :relation
      def path
        self.name.demodulize.pluralize.downcase
      end
    protected
      def relation
        Relation.new(self)
      end
    end
  end

  class Bid < Model
    attr_accessor :KeywordId, :Bid, :ContextBid
  end

  class Campaign < Model
    attr_accessor :Id, :Name
  end

  def self.decode(object, response)
    response['result'][object.name.pluralize.demodulize].map{ |attributes| object.new(attributes) }
  end

  def self.encode(object)
    object.to_json
  end

  def self.request(method, path, params = nil)
    connection = Faraday.new(url: SERVICE) do |faraday|
      faraday.adapter  Faraday.default_adapter
    end
    response = connection.post(path, {
        'method' => method,
        'params' => params || {}
    }.to_json, {
        'Authorization' => 'Bearer f0db0f69f2e54bedba7f1cc23f336714',
        'Client-Login' => 'eshurmin',
        'Accept-Language' => 'ru',
        'Content-Type' => 'application/json; charset=utf-8'
    })

    response = JSON.parse(response.body)

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
