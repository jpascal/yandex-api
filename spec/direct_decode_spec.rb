require 'spec_helper'

describe Yandex::API::Direct do
  let(:params) {{
      'Bid' => 10000,
      'KeywordId' => 1574449505,
      'ContextBid' => 0
  }}
  let(:response) {"{\"result\":{\"Bids\":[#{params.to_json}]}}"}

  it '#decode' do
    expect(subject.decode(response).first.class).to eql(Yandex::API::Direct::Bid)
  end
  it '#encode' do
    expect(subject.encode(Yandex::API::Direct::Bid.new(params))).to eql(params.to_json)
  end
  describe '#selection' do
    it 'no params' do
      expect(subject.selection).to eql({'SelectionCriteria' =>{}, 'FieldNames' =>[]})
    end
    it 'with criteria' do
      expect(subject.selection({:Bid => 1})).to eql({'SelectionCriteria' =>{:Bid=>1}, 'FieldNames' =>[]})
    end
    it 'with fields' do
      expect(subject.selection(nil, :Bid)).to eql({'SelectionCriteria' =>{}, 'FieldNames' =>[:Bid]})
    end
  end
  it '#namespace' do
    class Yandex::TestExample; end
    expect(subject.namespace(Yandex::TestExample)).to eql('testexamples')
  end
  it '#request' do
    subject.request(:get, subject.namespace(Yandex::API::Direct::Bid), subject.selection)
  end
end