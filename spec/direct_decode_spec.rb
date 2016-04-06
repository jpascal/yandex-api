require 'spec_helper'

describe Yandex::API::Direct do
  before { Yandex::API::Direct.load(File.join(File.dirname(__FILE__), '../yandex_direct.yml'), :test) }
  it '#relation' do
    puts Yandex::API::Direct::Campaign.get.inspect
  end
end