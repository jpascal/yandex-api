module Yandex::API::Direct
  class Base::HashSerializer
    attr_accessor :item

    def initialize(item)
      @item = item
    end

    def result
      result = {}
      # build hash of attributes
      item.class.attributes.each do |attribute|
        value = item.send(attribute)
        next if value.nil?
        result[attribute] = value
      end
      # build hash of arrays
      item.class.arrays.each do |array, _type|
        data_array = itemsend(array) || []
        next if data_array.empty?
        result[array] = []
        data_array.each do |data|
          result[array] << data.to_hash
        end
      end
      # build hash of objects
      item.class.objects.each do |name, _|
        object = item.send(name)
        next if object.nil?
        value_hash = send(name).to_hash || {}
        next if value_hash.empty?
        result[name] = value_hash
      end
      result
    end
  end
end
