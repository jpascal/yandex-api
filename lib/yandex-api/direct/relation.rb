module Yandex::API::Direct
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
end
