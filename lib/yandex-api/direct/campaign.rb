module Yandex::API::Direct
  class Campaign < Base
    fields :Id, :Name

    def self.get(id)
      self.select(self.attributes).where(Ids: Array(id)).limit(1).operation(:get).first
    end

    def self.all
      self.select(self.attributes).operation(:get)
    end

    def archive
      (self.errors = self.class.where(Ids: [self.Id]).function(:archive, :ArchiveResults).first).success?
    end

    def unarchive
      (self.errors = self.class.where(Ids: [self.Id]).function(:unarchive, :UnarchiveResults).first).success?
    end

    def resume
      (self.errors = self.class.where(Ids: [self.Id]).function(:resume, :ResumeResults).first).success?
    end

    def suspend
      (self.errors = self.class.where(Ids: [self.Id]).function(:suspend, :SuspendResults).first).success?
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
