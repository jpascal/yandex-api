require 'spec_helper'

describe Yandex::API::Direct do
  before { Yandex::API::Direct.load(File.join(File.dirname(__FILE__), '../yandex_direct.yml'), :test) }
  it '#relation' do
    s = Yandex::API::Direct::Campaign.get(131133)
    s.archive
    s.unarchive
    Yandex::API::Direct::Campaign.all
  end
end