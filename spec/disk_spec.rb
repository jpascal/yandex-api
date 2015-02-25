require 'spec_helper'

describe Yandex::API::Disk do
  before { Yandex::API::Disk.load File.join(File.dirname(__FILE__),'yandex_disk.yml'), :test }
  let (:storage) { Yandex::API::Disk::Storage.new }
  it 'config' do
    expect(Yandex::API::Disk.configuration).not_to be_nil
  end

  it 'ls' do
    expect(storage.ls('disk:/').any?).to be_truthy
  end

  it 'create/remove directory' do
    expect(storage.mkdir!('disk:/test')).to eql(true)
    expect(storage.rm!('disk:/test')).to eql(true)
  end

  it 'write/remove file' do
    file = File.open(__FILE__)
    expect(storage.write!(file, 'disk:/test.rb')).to eql(true)
    expect(storage.rm!('disk:/test.rb')).to eql(true)
  end

  it 'upload/move file' do
    file = File.open(__FILE__)
    expect(storage.write!(file, 'disk:/test.rb')).to eql(true)
    expect(storage.move!('disk:/test.rb', 'disk:/test33.rb')).to eql(true)
    expect(storage.rm('disk:/test33.rb')).to eql(true)
  end

  it 'upload/copy file' do
    file = File.open(__FILE__)
    expect(storage.write!(file, 'disk:/test.rb')).to eql(true)
    expect(storage.copy!('disk:/test.rb', 'disk:/test33.rb')).to eql(true)
    expect(storage.rm('disk:/test33.rb')).to eql(true)
    expect(storage.rm('disk:/test.rb')).to eql(true)
  end

  after do
    storage.rm!('disk:/test')
    storage.rm!('disk:/test.rb')
    storage.rm!('disk:/test33.rb')
  end
end
