module Yandex
  module API
    module Direct
      class ExceptionNotification
        include ActiveModel::Model
        attr_accessor :Message, :Details, :Code
      end
    end
  end
end
