module Yandex::API::Direct
  class Base
    def self.attributes
      @attributes || []
    end

    def self.direct_attributes(*args)
      args.map do |arg|
        class_eval("def #{arg};@#{arg};end")
        class_eval("def #{arg}=(val);@#{arg}=val;end")
        arg
      end
    end

    def self.objects
      @objects || []
    end

    def self.direct_objects(options)
      options.map do |name, type|
        class_eval("def #{name};@#{name};end")
        class_eval("def #{name}=(val);@#{name}=val;end")
        [name, type]
      end
    end

    def self.arrays
      @arrays || []
    end

    def self.direct_arrays(options)
      options.map do |name, type|
        class_eval("def #{name};@#{name};end")
        class_eval("def #{name}=(val);@#{name}=val;end")
        [name, type]
      end
    end

    def to_hash
      HashSerializer.new(self).result
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
