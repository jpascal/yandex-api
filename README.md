# Yandex::API

<a href="http://badge.fury.io/rb/yandex-api"><img src="https://badge.fury.io/rb/yandex-api@2x.png" alt="Gem Version" height="18"></a>

Позволяет работать с сервисами Яндекс доступными через API 

Доступные модули:
*   Direct - Автоматизация рекламных кампаний в Яндекс.Директе (http://direct.yandex.ru/)
*   Translate - Позволяет получить доступ к онлайн-сервису машинного перевода Яндекса (http://translate.yandex.ru/)

## Установка

Добавить в Gemfile эту строчку:

    gem 'yandex-api'

Выполнить команду:

    $ bundle

Или уставновить через gem:

    $ gem install yandex-api


## Direct
### в Ruby:

Создать конфигурационный файл yandex_direct.yml

    token: token
    login: login
    locale: ru
    verbose: true
    sandbox: true

### в Ruby On Rails:

Создать конфигурационный файл yandex_direct.yml

    development:
        token: token
        login: login
        locale: ru
        verbose: true
        sandbox: true

Добавить в initializers файл yandex_direct.rb

    Yandex::API::Direct.load File.join(Rails.root,"config","yandex_direct.yml"), Rails.env

### Пример работы:

    require 'yandex-api'
    Yandex::API::Direct.load "yandex_direct.yml"

    campaign = Yandex::API::Direct::CampaignInfo.list.first
    puts campaign.inspect
    puts campaign.banners.first.inspect

## Translate
### в Ruby:

Создать конфигурационный файл yandex_direct.yml

    token: "token"
    ui: true
    verbose: true

### в Ruby On Rails:

Создать конфигурационный файл yandex_translate.yml

    development:
	    token: "token"
        ui: "ru"
        verbose: true
        
Добавить в initializers файл yandex_translate.rb

    Yandex::API::Translate.load File.join(Rails.root,"config","yandex_translate.yml"), Rails.env


### Пример работы

    require 'yandex-api'
    Yandex::API::Translate.load "yandex.yml", "production"

    puts Yandex::API::Translate.languages.inspect
    puts Yandex::API::Translate.detect('test').inspect
    puts Yandex::API::Translate.do('Hello GitHub', 'ru').inspect


## Contributing

1. Fork it ( https://github.com/jpascal/yandex-api/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request