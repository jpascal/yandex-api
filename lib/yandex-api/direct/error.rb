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
end
