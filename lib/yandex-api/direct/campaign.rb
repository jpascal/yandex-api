module Yandex::API::Direct
  class Campaign < Base
    fields :Id, :Name

    def self.get(id)
      self.select(self.attributes).where(Ids: Array(id)).limit(1).call(:get).first
    end

    def self.all
      self.select(self.attributes).call(:get)
    end

    def archive
      self.class.where(Ids: [self.Id]).call(:archive)
    end

    def unarchive
      self.class.where(Ids: [self.Id]).call(:unarchive)
    end

    # add
    # update
    # delete
    # suspend
    # resume
    # archive
    # unarchive
    # get
  end
end
