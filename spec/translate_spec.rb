require 'spec_helper'

describe Yandex::API::Translate do
  before { Yandex::API::Translate.load File.join(File.dirname(__FILE__),'yandex_translate.yml'), :test }
  it 'config' do
    expect(Yandex::API::Translate.configuration).not_to be_nil
  end
  it 'languages' do
    languages = Yandex::API::Translate.languages
    expect(languages).to have_key('dirs')
    expect(languages['dirs']).to include('ru-en')
  end
  it 'detect' do
    expect(Yandex::API::Translate.detect('Ruby')).to eql('en')
    expect(Yandex::API::Translate.detect('Руби')).to eql('ru')
  end
  it 'translate' do
    result = Yandex::API::Translate.do('Рубин', :en)
    expect(result).to have_key('code')
    expect(result).to have_key('lang')
    expect(result).to have_key('text')
    expect(result['lang']).to eql('ru-en')
    expect(result['text']).to include('Ruby')
  end
end
