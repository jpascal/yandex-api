require 'spec_helper'

describe Yandex::API::Direct do
  before { Yandex::API::Direct.load(File.join(File.dirname(__FILE__), '../yandex_direct.yml'), :test) }
  it '#relation' do
    # puts Yandex::API::Direct::Campaign.call(:get)
    # puts Yandex::API::Direct::Campaign.where(Ids: [131133]).call(:archive).first.inspect
    campaign = Yandex::API::Direct::Campaign.find(131133)
    puts campaign.inspect
    # puts campaign.delete.inspect
  end
end