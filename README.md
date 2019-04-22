# Currency Converter

## Introduction

This is a simple currency converter that uses free version of: https://free.currencyconverterapi.com/ to get the current exchange rate.

## Dependencies
This script requires you to install the following dependencies by yourself:
- [Ruby v2.6.0](https://www.ruby-lang.org/en/downloads/)
- [Bundler v1.17.2](https://bundler.io/)

### Installation
Run `bundle install` to install the following in the project:
- [Ruby Money v6.13.3](https://github.com/RubyMoney/money)
- [Curb v0.9.10](https://github.com/taf2/curb)
- [Webmock v1.24.3](https://github.com/bblimke/webmock)

## Usage
  ```
  $ ruby lib/currency_converter.rb amount_in_source_currency source_currency target_currency options
  ```

## Examples
  ```
  $ ruby lib/currency_converter.rb 100 PHP USD
    Exchange Rate: 0.01935
    1.94 USD
  $ ruby lib/currency_converter.rb 1223.12 SGD GBP
    Exchange rate: 0.568083
    694.82 GBP
  ```

## Available Options
 --with-exchange-rate Prints exchange rate used in conversion
 ```
 $ ruby lib/currency_converter.rb 100 PHP USD --with-exchange-rate
    Exchange Rate: 0.01935
    1.94
 ```
 --with-currency Prints target currency
 ```
 $ ruby lib/currency_converter.rb 1223.12 SGD GBP --with-currency
    1.94 GBP
 ```

## Run Tests
 ```
 $ rspec
 ```

## Notes
- Currencies are ALL CAPS in 3-letter code as defined by ISO 4217
- Amount only accepts number of decimal places depending on the currency as defined by ISO 4217
