require 'yandex-api/version'
require 'yandex-api/direct'
require 'yandex-api/translate'
require 'yandex-api/disk'

module Yandex
  module API
    class RuntimeError < RuntimeError; end
    class NotFound < RuntimeError; end
  end
end
