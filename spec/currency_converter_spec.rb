require 'spec_helper.rb'
require './lib/currency_converter'

RSpec.describe 'currency_converter' do
  describe 'validate_currencies' do
    context 'when currencies are valid' do
      it 'returns empty hash' do
        VCR.use_cassette 'get_currencies' do
          expect(validate_currencies('PHP', 'BHD')).to eq(errors: [])
        end
      end
    end

    context 'when source currency is invalid' do
      it 'returns hash with an array of error for source currency' do
        VCR.use_cassette 'get_currencies' do
          expect(validate_currencies('AB', 'PHP')).to eq(
            errors: ['Source currency not supported.']
          )
        end
      end
    end

    context 'when target currency is invalid' do
      it 'returns hash with an array of error for target currency' do
        VCR.use_cassette 'get_currencies' do
          expect(validate_currencies('USD', 'MNO')).to eq(
            errors: ['Target currency not supported.']
          )
        end
      end
    end

    context 'when both currencies are invalid' do
      it 'returns hash with an array of errors' do
        VCR.use_cassette 'get_currencies' do
          expect(validate_currencies('AB', 'MGK')).to eq(
            errors: ['Source currency not supported.', 'Target currency not supported.']
          )
        end
      end
    end
  end

  describe 'valid_amount?' do
    it 'returns true when numeric and decimal places of amount is valid' do
      expect(valid_amount?('1', 0)).to be_truthy
    end

    it 'returns false when decimal places of amount is invalid' do
      expect(valid_amount?('1.0000', 2)).to be_falsey
    end

    it 'returns false when amount is invalid' do
      expect(valid_amount?('qrjqo23rqlwrqw', 2)).to be_falsey
    end
  end

  describe 'get(url)' do
    let(:test_url) { 'https://free.currconv.com/api/v7/convert?q=PHP_USD&compact=ultra&apiKey=e360c6122d3dfff462d2' }

    it 'returns hash when request is successful' do
      VCR.use_cassette 'get_exchange_rate' do
        expect(get(test_url)).to have_key('PHP_USD')
      end
    end

    context 'when request is not successful' do
      let(:test_url) { 'https://free.currconv.com/api/v7/convert?q=PHP_USD&compact=ultra&apiKey=e360c6' }

      it 'raises an error' do
        VCR.use_cassette 'get_failure' do
          expect { get(test_url) }.to raise_error('Error occurred while connecting to the converter.')
        end
      end
    end
  end

  describe 'convert' do
    before(:example) do
      I18n.available_locales = :en
      Money.locale_backend = :i18n
      VCR.use_cassette('get_exchange_rate') do
        update_exchange_rate('PHP', 'USD', [])
      end
    end
    context 'with-currency option is enabled' do
      it 'returns converted money with currency' do
        VCR.use_cassette 'get_exchange_rate' do
          expect(convert('10000_00', 'PHP', 'USD', ['--with-currency'])).to eq('193.18 USD')
        end
      end
    end

    context 'with-currency option is disabled' do
      it 'returns converted money with no currency' do
        VCR.use_cassette 'get_exchange_rate' do
          expect(convert('10000_00', 'PHP', 'USD', [])).to eq('193.18')
        end
      end
    end
  end

  describe 'retrieve_options' do
    it 'returns empty array when there are no options' do
      expect(retrieve_options(['100', 'PHP', 'USD'])).to be_empty
    end

    context 'when all options are valid' do
      it 'returns options' do
        expect(retrieve_options(['100', 'PHP', 'USD', '--with-currency']))
          .to eq(['--with-currency'])
      end
    end

    it 'returns empty array when there are invalid options' do
      expect(retrieve_options(['100', 'PHP', 'USD', '--with-cury1'])).to be_empty
    end
  end
end
