module Yandex::API::Direct
  class Base
    include ActiveModel::Model
    include ActiveModel::Serialization
    attr_accessor :errors
    class << self
      def initialize(*args)
        self.errors = []
        super
      end
      def fields(*args)
        @attributes = *args
        attr_accessor *args
      end
      def attributes
        @attributes
      end
      delegate :select, :limit, :offset, :where, to: :request
      def path
        self.name.demodulize.pluralize.downcase
      end
    protected
      def request
        Request.new(self)
      end
    end
  end
end
