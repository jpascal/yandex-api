#
# Взаимодействие с API Яндекс.Директа в формате JSON.
# http://api.yandex.ru/direct/doc/concepts/JSON.xml
#
# (c) Copyright 2012 Евгений Шурмин. All Rights Reserved. 
#

module Yandex::API
  module Direct
    #
    # = CampaignStrategy
    #
    class CampaignStrategy < Base
      direct_attributes :StrategyName, :MaxPrice, :AveragePrice, :WeeklySumLimit, :ClicksPerWeek
    end
    
    #
    # = SmsNotification
    #
    class SmsNotification < Base
      direct_attributes :MetricaSms, :ModerateResultSms, :MoneyInSms, :MoneyOutSms, :SmsTimeFrom, :SmsTimeTo
    end
    
    #
    # = EmailNotification
    #
    class EmailNotification < Base
      direct_attributes :Email, :WarnPlaceInterval, :MoneyWarningValue, :SendAccNews, :SendWarn
    end
    
    #
    # = TimeTargetInfo
    #
    class TimeTarget < Base
      direct_attributes :ShowOnHolidays, :HolidayShowFrom, :HolidayShowTo, :DaysHours, :TimeZone  
    end

    #
    # = TimeTargetItem
    #
    class TimeTargetItem < Base
      direct_attributes :Days, :Hours  
    end
    #
    # = CampaignInfo
    #
    class CampaignInfo < Base
      direct_attributes :Login, :CampaignID, :Name, :FIO, :StartDate, :StatusBehavior, :StatusContextStop, :ContextLimit, :ContextLimitSum, :ContextPricePercent,
              :AutoOptimization, :StatusMetricaControl, :DisabledDomains, :DisabledIps, :StatusOpenStat, :ConsiderTimeTarget, :MinusKeywords, :AddRelevantPhrases,
              :RelevantPhrasesBudgetLimit
      direct_objects :Strategy => CampaignStrategy, :SmsNotification => SmsNotification, :EmailNotification => EmailNotification, :TimeTarget => TimeTarget
      
      def banners
        banners = []
        Direct::request('GetBanners', {:CampaignIDS => [self.CampaignID]}).each do |banner|
          banners << BannerInfo.new(banner)
        end
        banners
      end
      def save
        Direct::request('CreateOrUpdateCampaign', self.to_hash)
      end
      def archive
        Direct::request('ArchiveCampaign', {:CampaignID => self.CampaignID})
      end
      def unarchive
        Direct::request('UnArchiveCampaign', {:CampaignID => self.CampaignID})
      end
      def resume
        Direct::request('ResumeCampaign', {:CampaignID => self.CampaignID})
      end
      def stop
        Direct::request('StopCampaign', {:CampaignID => self.CampaignID})
      end
      def delete
        Direct::request('DeleteCampaign', {:CampaignID => self.CampaignID})
      end
      def self.find id
        result = Direct::request('GetCampaignParams', {:CampaignID => id})
        raise Yandex::NotFound.new("not found campaign where CampaignID = #{id}") if result.empty?
        new(result)
      end
      def self.list
        campaigs = []
        Direct::request('GetCampaignsList').each do |campaig|
          campaigs << new(campaig)
        end
        campaigs 
      end
    end
  end
end