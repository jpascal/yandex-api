# encoding: UTF-8
#
# Взаимодействие с API Яндекс.Директа в формате JSON.
# http://api.yandex.ru/direct/doc/concepts/JSON.xml
#
# (c) Copyright 2012 Евгений Шурмин. All Rights Reserved. 
#

module Yandex::API
  module Direct
    #
    # = PhraseUserParams
    #
    class PhraseUserParams < Base
      direct_attributes :Param1, :Param2
    end
    #
    # = Phrases
    #
    class BannerPhraseInfo < Base
      direct_attributes :PhraseID, :Phrase, :IsRubric, :Price, :AutoBudgetPriority, :ContextPrice, :AutoBroker
      direct_objects [:UserParams, PhraseUserParams]
    end
    
    #
    # = Sitelink
    #
    class Sitelink < Base
      direct_attributes :Title, :Href
    end
    
    #
    # = MapPoint
    #
    class MapPoint < Base
      direct_attributes :x, :y, :x1, :y1, :x2, :y2
    end
    
    #
    # = ContactInfo
    #
    class ContactInfo < Base
      direct_attributes :CompanyName, :ContactPerson, :Country, :CountryCode, :City, :Street, :House, :Build,
        :Apart, :CityCode, :Phone, :PhoneExt, :IMClient, :IMLogin, :ExtraMessage, :ContactEmail, :WorkTime, :OGRN
      direct_objects [:PointOnMap, MapPoint]
    end
    
    #
    # = Banner
    #
    class BannerInfo < Base
      direct_attributes :BannerID, :CampaignID, :Title, :Text, :Href, :Geo, :MinusKeywords
      direct_arrays [:Phrases, BannerPhraseInfo], [:Sitelinks, Sitelink]
      direct_objects [:ContactInfo, ContactInfo]
      def self.find id
        result = Direct::request('GetBanners', {:BannerIDS => [id]})
        raise Yandex::NotFound.new("not found banner where id = #{id}") unless result.any?
        banner = new(result.first)
      end
      def save
        Direct::request('CreateOrUpdateBanners', [self.to_hash]).first
      end

      def archive
        Direct::request('ArchiveBanners', {:CampaignID => self.CampaignID, :BannerIDS => [self.BannerID]})
      end
      def unarchive
        Direct::request('UnArchiveCampaign', {:CampaignID => self.CampaignID, :BannerIDS => [self.BannerID]})
      end
      def moderate
        Direct::request('ModerateBanners', {:CampaignID => self.CampaignID, :BannerIDS => [self.BannerID]})
      end
      def resume
        Direct::request('ResumeBanners', {:CampaignID => self.CampaignID, :BannerIDS => [self.BannerID]})
      end
      def stop
        Direct::request('StopBanners', {:CampaignID => self.CampaignID, :BannerIDS => [self.BannerID]})
      end
      def delete
        Direct::request('DeleteBanners', {:CampaignID => self.CampaignID, :BannerIDS => [self.BannerID]})
      end
    end
  end
end