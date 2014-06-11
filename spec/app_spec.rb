ENV['RACK_ENV'] = 'test'
require './spec/spec_helper.rb'
require './app/main.rb'

describe 'UECLunch' do
  include Rack::Test::Methods
  def app
    UECLunch::Application
  end

  describe '/' do
    before { get '/'}
    it '200が返ってくる' do
      expect(last_response).to be_ok
    end

    it '正しいJSONである' do
      json = JSON.parse(last_response.body)
      expect(json['message']).to eq('It works!')
    end
  end

  describe '/uec-lunch' do
    before { get '/uec-lunch'}
    it '200が返ってくる' do
      expect(last_response).to be_ok
    end

    it '正しいJSONである' do
      json = JSON.parse(last_response.body)
      expect(json['message']).to eq('uec lunch')
    end
  end

  describe '/uec-lunch/nishishoku/2000-01-01/menu.json' do
    before do
      @menu = FactoryGirl.create(:nishishoku_menu)
      get '/uec-lunch/nishishoku/2000-01-01/menu.json'
    end

    it '200が返ってくる' do
      expect(last_response).to be_ok
    end

    it '正しいJSONである' do
      json = JSON.parse(last_response.body)
      expect(json['date']).to eq('2000-01-01')
      expect(json['a_set']).to eq('hoge')
      expect(json['b_set']).to eq('fuga')
      expect(json['higawari']).to eq('piyo')
    end
  end

  describe '/uec-lunch/nishishoku/1991-12-31/menu.json' do
    before do
      @menu = FactoryGirl.create(:nishishoku_menu)
      get '/uec-lunch/nishishoku/1991-12-31/menu.json'
    end

    it '200が返ってくる' do
      expect(last_response).to be_ok
    end

    it 'エラーJSONが返ってくる' do
      json = JSON.parse(last_response.body)
      error = json['errors'][0]
      expect(error['message']).to eq('No such entry.')
      expect(error['code']).to eq(404)
    end
  end

  describe '/uec-lunch/nishishoku/2000-01-01/menu.jso' do
    before do
      @menu = FactoryGirl.create(:nishishoku_menu)
      get '/uec-lunch/nishishoku/2000-01-01/menu.jso'
    end

    it '404が返ってくる' do
      expect(last_response.status).to eq(404)
    end

    it 'エラーJSONが返ってくる' do
      json = JSON.parse(last_response.body)
      error = json['errors'][0]
      expect(error['message']).to eq('Not found.')
      expect(error['code']).to eq(404)
    end
  end

  describe '/uec-lunch/harmonia/2000-01-01/menu.json' do
    before do
      @menu = FactoryGirl.create(:harmonia_menu)
      get '/uec-lunch/harmonia/2000-01-01/menu.json'
    end

    it '200が返ってくる' do
      expect(last_response).to be_ok
    end

    it '正しいJSONである' do
      json = JSON.parse(last_response.body)
      expect(json['date']).to eq('2000-01-01')
      expect(json['special']).to eq('hoge')
      expect(json['higawari']).to eq('fuga')
      expect(json['osusume']).to eq('piyo')
      expect(json['s_lunch']).to eq('foo')
      expect(json['noodle']).to eq('bar')
      expect(json['s_dinner']).to eq('foobar')
    end
  end

  describe '/uec-lunch/harmonia/1991-12-31/menu.json' do
    before do
      @menu = FactoryGirl.create(:nishishoku_menu)
      get '/uec-lunch/harmonia/1991-12-31/menu.json'
    end

    it '200が返ってくる' do
      expect(last_response).to be_ok
    end

    it 'エラーJSONが返ってくる' do
      json = JSON.parse(last_response.body)
      error = json['errors'][0]
      expect(error['message']).to eq('No such entry.')
      expect(error['code']).to eq(404)
    end
  end


  describe '/uec-lunch/harmonia/2000-01-01/menu.jso' do
    before do
      @menu = FactoryGirl.create(:harmonia_menu)
      get '/uec-lunch/harmonia/2000-01-01/menu.jso'
    end

    it '404が返ってくる' do
      expect(last_response.status).to eq(404)
    end

    it 'エラーJSONである' do
      json = JSON.parse(last_response.body)
      error = json['errors'][0]
      expect(error['message']).to eq('Not found.')
      expect(error['code']).to eq(404)
    end
  end
end
