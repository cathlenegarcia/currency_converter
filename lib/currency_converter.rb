# frozen_string_literal: true
require 'rubygems'
require 'bundler/setup'

Bundler.require(:default)

API_KEY = 'e360c6122d3dfff462d2'.freeze
BASE_URL = 'https://free.currconv.com/api/v7'.freeze

def validate_currencies(source_currency, target_currency)
  url_for_list_of_currencies = "#{BASE_URL}/currencies?apiKey=#{API_KEY}"
  supported_currencies = get(url_for_list_of_currencies).dig('results')
  response = { errors: [] }
  unless supported_currencies[source_currency]
    response[:errors] << 'Source currency not supported.'
  end
  unless supported_currencies[target_currency]
    response[:errors] << 'Target currency not supported.'
  end
  response
end

def valid_amount?(amount, max_decimal)
  regex = /^\d*$/
  regex = /^\d*\.?\d{1,#{max_decimal}}$/ if max_decimal > 0
  regex_match = regex.match(amount)
  if regex_match.nil?
    puts "Amount must be numeric with up to #{max_decimal} decimal places."
    return false
  end
  true
end

def get(url)
  begin
    result = Curl.get(url)
  rescue Curl::Err::CurlError => e # for logging
    puts 'Error occurred while connecting to the converter.'
    raise e
  end
  raise 'Error occurred while connecting to the converter.' if
    result.response_code != 200
  JSON.parse(result.body_str)
end

def update_exchange_rate(source_currency, target_currency, options)
  url = "#{BASE_URL}/convert?q=#{source_currency}_#{target_currency}" \
    "&compact=ultra&apiKey=#{API_KEY}"
  rate = get(url).dig("#{source_currency}_#{target_currency}")
  with_exchange_rate = true if options.include?('--with-exchange-rate')
  puts "Exchange rate: #{rate}" if with_exchange_rate
  Money.add_rate(source_currency, target_currency, rate)
end

def convert(amount, source_currency, target_currency, options)
  update_exchange_rate(source_currency, target_currency, options)
  money = Money.new(amount, source_currency)
  converted_money = money.exchange_to(target_currency)
  with_currency = false
  with_currency = true if options.include?('--with-currency')
  formatted_money = converted_money.format(with_currency: with_currency, symbol: false)
  puts formatted_money
  formatted_money
end

def retrieve_options(arguments)
  options = arguments.slice(3, arguments.size + 1)
  available_options = %w(--with-currency --with-exchange-rate)
  return options if (available_options & options).size == options.size
  puts 'Invalid option/s. Available options:'
  puts available_options
  []
end

if ARGV.length >= 3
  I18n.available_locales = :en
  Money.locale_backend = :i18n

  raw_amount, source_currency, target_currency = ARGV
  options = retrieve_options(ARGV)

  response = validate_currencies(source_currency, target_currency)
  if response[:errors].empty?
    max_decimal = Money::Currency.new(source_currency).exponent
    if valid_amount?(raw_amount, max_decimal)
      amount = format("%.#{max_decimal}f", raw_amount).tr('.', '_')
      convert(amount, source_currency, target_currency, options)
    end
  else
    puts response[:errors]
  end
else
  puts 'Usage: currency_converter.rb amount source_currency target_currency'
end
