module Yandex::API::Direct
  class Base
    def self.attributes ; @attributes || [] ; end 
    def self.direct_attributes *args
      @attributes = []
      args.each do |arg|
        @attributes << arg
        self.class_eval("def #{arg};@#{arg};end")
        self.class_eval("def #{arg}=(val);@#{arg}=val;end")
      end
    end
    def self.objects ; @objects || [] ; end 
    def self.direct_objects options
      @objects = []
      options.each do |name,type|
        @objects << [name,type]
        self.class_eval("def #{name};@#{name};end")
        self.class_eval("def #{name}=(val);@#{name}=val;end")
      end
    end
    def self.arrays ; @arrays || [] ; end 
    def self.direct_arrays options
      @arrays = []
      options.each do |name,type|
        @arrays << [name,type]
        self.class_eval("def #{name};@#{name};end")
        self.class_eval("def #{name}=(val);@#{name}=val;end")
      end
    end
    def to_hash
      result = {}
      # build hash of attributes
      self.class.attributes.each do |attribute|
        value = send(attribute)
        next unless not value.nil?
        result[attribute] = value
      end
      # build hash of arrays
      self.class.arrays.each do |array,type|
        data_array = send(array)|| []
        next if data_array.empty?
        result[array] = []
        data_array.each do |data|
          result[array] << data.to_hash
        end
      end
      # build hash of objects
      self.class.objects.each do |name,_|
        object = send(name)
        next if object.nil?
        value_hash = send(name).to_hash || {}
        next if value_hash.empty?
        result[name] = value_hash
      end
      result
    end
    def initialize(params = {})
      params.each do |key, value|
        object = self.class.objects.find{|s| s.first.to_sym == key.to_sym}
        array = self.class.arrays.find{|s| s.first.to_sym == key.to_sym}
        if object
          send("#{key}=", object.last.new(value))
        elsif array
          send("#{key}=", value.collect {|element| array.last.new(element)})
        else
          send("#{key}=", value) if respond_to? "#{key}="
        end
      end
    end
  end
end