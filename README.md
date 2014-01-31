# Yandex::API

<a href="http://badge.fury.io/rb/yandex-api"><img src="https://badge.fury.io/rb/yandex-api@2x.png" alt="Gem Version" height="18"></a>

Позволяет работать с сервисами Яндекс доступными через API 

Доступные модули:
*   Direct - Автоматизация рекламных кампаний в Яндекс.Директе (http://direct.yandex.ru/)

## Установка

Добавить в Gemfile эту строчку:

    gem 'yandex-api'

Выполнить команду:

    $ bundle

Или уставновить через gem:

    $ gem install yandex-api

## в Ruby:

Создать конфигурационный файл yandex_direct.yml

    token: "token"
    application_id: "id"
    login: "login"
    locale: "ru"
    verbose: true

## в Ruby On Rails:

Создать конфигурационный файл yandex_direct.yml

    development:
	    token: "token"
	    application_id: "id"
	    login: "login"
	    locale: "ru"
	    verbose: true

Добавить в initializers файл yandex_direct.rb

    Yandex::API::Direct.load File.join(Rails.root,"config","yandex_direct.yml"), Rails.env

## Пример работы:

    require 'yandex-api'
    Yandex::API::Direct.load "yandex_direct.yml"

    campaign = Yandex::API::Direct::CampaignInfo.list.first
    puts campaign.inspect
    puts campaign.banners.first.inspect
