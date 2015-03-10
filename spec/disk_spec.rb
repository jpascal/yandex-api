require 'spec_helper'
include Yandex::API::Disk

describe Yandex::API::Disk do
  before { Yandex::API::Disk.load File.join(File.dirname(__FILE__),'yandex_disk.yml'), :test }
  it 'config' do
    expect {Storage.new}.not_to raise_error
  end
  it 'ls' do
    expect(Storage.ls('disk:/').any?).to be_truthy
  end
  it 'create/remove directory' do
    expect(Storage.mkdir!('disk:/test')).to eql(true)
    expect(Storage.rm!('disk:/test')).to eql(true)
    expect(Storage.clean!('test')).to eql(true)
  end
  it 'write/remove file' do
    file = File.open(__FILE__)
    expect(Storage.write!(file, 'disk:/test.rb')).to eql(true)
    expect(Storage.rm!('disk:/test.rb')).to eql(true)
    expect(Storage.clean!('test.rb')).to eql(true)
  end
  it 'write/move file' do
    file = File.open(__FILE__)
    expect(Storage.write!(file, 'disk:/test.rb')).to eql(true)
    expect(Storage.move!('disk:/test.rb', 'disk:/test33.rb')).to eql(true)
    expect(Storage.rm!('disk:/test33.rb')).to eql(true)
    expect(Storage.clean!('test33.rb')).to eql(true)
  end
  it 'write/copy file' do
    file = File.open(__FILE__)
    expect(Storage.write!(file, 'disk:/test.rb')).to eql(true)
    expect(Storage.copy!('disk:/test.rb', 'disk:/test33.rb')).to eql(true)
    expect(Storage.rm!('disk:/test33.rb')).to eql(true)
    expect(Storage.rm!('disk:/test.rb')).to eql(true)
    expect(Storage.clean!('test.rb')).to eql(true)
    expect(Storage.clean!('test33.rb')).to eql(true)
  end
  it 'write/remove/clean' do
    file = File.open(__FILE__)
    expect(Storage.write!(file, 'disk:/test.rb')).to eql(true)
    expect(Storage.rm!('disk:/test.rb')).to eql(true)
    expect(Storage.clean!('/test.rb')).to eql(true)
    expect(Storage.clean!('test.rb')).to eql(true)
  end

  it 'write/remove/restore' do
    file = File.open(__FILE__)
    expect(Storage.write!(file, 'disk:/test.rb')).to eql(true)
    expect(Storage.rm!('disk:/test.rb')).to eql(true)
    expect(Storage.restore!('/test.rb')).to eql(true)
    expect(Storage.rm!('disk:/test.rb')).to eql(true)
    expect(Storage.clean!('test.rb')).to eql(true)
  end
end
