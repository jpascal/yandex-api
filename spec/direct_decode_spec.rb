require 'spec_helper'

describe Yandex::API::Direct do
  before { Yandex::API::Direct.load(File.join(File.dirname(__FILE__), '../yandex_direct.yml'), :test) }
  it '#relation' do
    campaigns = Yandex::API::Direct::Campaign.all
    campaigns.each do |campaign|
      puts campaign.errors.inspect unless campaign.suspend
      puts campaign.errors.inspect unless campaign.resume
    end
  end
end