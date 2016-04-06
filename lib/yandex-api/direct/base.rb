module Yandex::API::Direct
  class Base
    include ActiveModel::Model
    include ActiveModel::Serialization
    class << self
      def fields(*args)
        @attributes = *args
        attr_accessor *args
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
end
