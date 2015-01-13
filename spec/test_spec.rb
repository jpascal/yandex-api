require 'spec_helper'

describe Yandex::API::Direct do
  before { Yandex::API::Direct.load File.join(File.dirname(__FILE__),'yandex_direct.yml'), :test }
  it 'config' do
    expect(Yandex::API::Direct.configuration).not_to be_nil
  end
end
