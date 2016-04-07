module Yandex::API::Direct
  class Base
    include ActiveModel::Model
    include ActiveModel::Serialization
    class << self
      def initialize(*args)
        super
      end
      delegate :call, :fields, :limit, :offset, :where, to: :selection_criteria
      def path
        self.name.demodulize.pluralize.downcase
      end
    protected
      def selection_criteria
        SelectionCriteria.new(self)
      end
    end
  end
end
