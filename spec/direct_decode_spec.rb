require 'spec_helper'

describe Yandex::API::Direct do
  # let(:params) {{
  #     'Bid' => 10000,
  #     'KeywordId' => 1574449505,
  #     'ContextBid' => 0
  # }}
  # let(:response) { {'result'=>{'Bids'=>[params]}} }
  #
  # it '#decode' do
  #   expect(subject.decode(Yandex::API::Direct::Bid, response).first.class).to eql(Yandex::API::Direct::Bid)
  # end
  # it '#encode' do
  #   expect(subject.encode(Yandex::API::Direct::Bid.new(params))).to eql(params.to_json)
  # end
  # describe '#selection' do
  #   it 'no params' do
  #     expect(subject.selection).to eql({'SelectionCriteria' =>{}, 'FieldNames' =>[]})
  #   end
  #   it 'with criteria' do
  #     expect(subject.selection({:Bid => 1})).to eql({'SelectionCriteria' =>{:Bid=>1}, 'FieldNames' =>[]})
  #   end
  #   it 'with fields' do
  #     expect(subject.selection(nil, :Bid)).to eql({'SelectionCriteria' =>{}, 'FieldNames' =>[:Bid]})
  #   end
  # end
  # it '#namespace' do
  #   class Yandex::TestExample < Yandex::API::Direct::Model; end
  #   expect(Yandex::TestExample.namespace).to eql('testexamples')
  # end
  # it '#request' do
  #   puts subject.request(:get, Yandex::API::Direct::Campaign, subject.selection({}, :Id, :Name)).inspect
  # end
  it '#relation' do
    puts Yandex::API::Direct::Campaign.get.inspect
  end
end