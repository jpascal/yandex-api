require 'yandex-api/version'
require 'yandex-api/direct'
require 'yandex-api/direct/base'
require 'yandex-api/direct/banner_info'
require 'yandex-api/direct/campaign_info'
require 'yandex-api/translate'
require 'yandex-api/disk'

module Yandex
  module API
    class RuntimeError < RuntimeError ; end
    class NotFound < RuntimeError ; end
  end
end
