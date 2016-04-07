module Yandex::API::Direct
  class Campaign < Base
    ATTRIBUTES = :Id, :Name, :ClientInfo, :StartDate, :EndDate, :TimeTargeting, :TimeZone, :NegativeKeywords,
        :BlockedIps, :ExcludedSites, :DailyBudget, :Notification, :Type, :Status, :State, :StatusPayment,
        :StatusClarification, :SourceId, :Statistics, :Currency, :Funds, :RepresentedBy

    attr_accessor *ATTRIBUTES

    def self.get(selection_criteria)
      response = Yandex::API::Direct.request('get', self.path, selection_criteria.fields(*ATTRIBUTES))
      response.fetch('Campaigns',[]).map{|attributes| self.new(attributes)}
    end

    def self.find(id)
      self.where(Ids: Array(id)).call(:get).first
    end

    def self.archive(selection_criteria)
      response = Yandex::API::Direct.request('archive', self.path, selection_criteria)
      response.fetch('ArchiveResults',[]).map{|attributes| Yandex::API::Direct::ActionResult.new(attributes)}
    end

    def archive
      self.class.where(Ids: [self.Id]).call(:archive).first
    end

    def self.unarchive(selection_criteria)
      response = Yandex::API::Direct.request('unarchive', self.path, selection_criteria)
      response.fetch('UnarchiveResults',[]).map{|attributes| Yandex::API::Direct::ActionResult.new(attributes)}
    end

    def unarchive
      self.class.where(Ids: [self.Id]).call(:unarchive).first
    end

    def self.resume(selection_criteria)
      response = Yandex::API::Direct.request('resume', self.path, selection_criteria)
      response.fetch('ResumeResults',[]).map{|attributes| Yandex::API::Direct::ActionResult.new(attributes)}
    end

    def resume
      self.class.where(Ids: [self.Id]).call(:resume).first
    end

    def self.suspend(selection_criteria)
      response = Yandex::API::Direct.request('suspend', self.path, selection_criteria)
      response.fetch('SuspendResults',[]).map{|attributes| Yandex::API::Direct::ActionResult.new(attributes)}
    end

    def suspend
      self.class.where(Ids: [self.Id]).call(:suspend).first
    end

    def self.delete(selection_criteria)
      response = Yandex::API::Direct.request('delete', self.path, selection_criteria)
      response.fetch('DeleteResults', []).map{|attributes| Yandex::API::Direct::ActionResult.new(attributes)}
    end

    def delete
      self.class.where(Ids: [self.Id]).call(:delete).first
    end

    # TODO: add, update
    # TODO: TextCampaign, DynamicTextCampaign, MobileAppCampaign

  end
end
