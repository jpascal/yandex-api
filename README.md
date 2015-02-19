# Yandex::API

<a href="http://badge.fury.io/rb/yandex-api"><img src="https://badge.fury.io/rb/yandex-api@2x.png" alt="Gem Version" height="18"></a>

Allow you work with any Yandex.APIs

Modules:

*  Direct - contain classes and methods for work with Yandex.Direct (http://direct.yandex.ru/)
*  Translate - contain methods for work with Yandex.Translate (http://translate.yandex.ru/)


## Installation

Add this line to your application's Gemfile:

```
gem 'yandex-api'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install yandex-api

## Direct
### в Ruby:

Create configuration file yandex_direct.yml

    token: token
    login: login
    locale: ru
    verbose: true
    sandbox: true

### в Ruby On Rails:

Create configuration file yandex_direct.yml

    development:
        token: token
        login: login
        locale: ru
        verbose: true
        sandbox: true

Create yandex_direct.rb in config/initializers

    Yandex::API::Direct.load File.join(Rails.root,"config","yandex_direct.yml"), Rails.env

### Simple example:

    require 'yandex-api'
    Yandex::API::Direct.load "yandex_direct.yml"

    campaign = Yandex::API::Direct::CampaignInfo.list.first
    puts campaign.inspect
    puts campaign.banners.first.inspect

## Translate
### в Ruby:

Create configuration file yandex_translate.yml

    token: "token"
    ui: true
    verbose: true

### в Ruby On Rails:

Create configuration file yandex_translate.yml

    development:
	    token: "token"
        ui: "ru"
        verbose: true
        
Create yandex_translate.rb in config/initializers

    Yandex::API::Translate.load File.join(Rails.root,"config","yandex_translate.yml"), Rails.env


### Simple example

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