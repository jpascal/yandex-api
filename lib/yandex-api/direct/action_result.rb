module Yandex
  module API
    module Direct
      class ActionMessage
        include ActiveModel::Model
        attr_accessor :Message, :Details, :Code
      end
      class ActionResult
        include ActiveModel::Model
        attr_accessor :Id, :Warnings, :Errors, :Function
        def initialize(*args)
          super
          self.Warnings = Array(self.Warnings).map{|attributes| ActionMessage.new(attributes)}
          self.Errors = Array(self.Errors).map{|attributes| ActionMessage.new(attributes)}
        end
        def errors?
          Array(self.Errors).compact.any?
        end
        def warnings?
          Array(self.Warnings).compact.any?
        end
        def success?
          !errors? and !warnings?
        end
      end
    end
  end
end
