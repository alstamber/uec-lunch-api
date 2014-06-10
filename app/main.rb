require 'sinatra/base'
require 'sinatra/reloader'
require 'json'
require 'nokogiri'
require 'open-uri'
require 'date'
require 'active_record'

module UECLunch
  ActiveRecord::Base.establish_connection(
    :adapter => 'sqlite3',
    :database => 'production.sqlite3'
  )

  class NishishokuMenu < ActiveRecord::Base
  end

  class HarmoniaMenu < ActiveRecord::Base
  end

  class Application < Sinatra::Base
    configure do
      register Sinatra::Reloader
    end

    get '/' do
      JSON.generate({message: 'It works!'})
    end

    get '/uec-lunch' do
      JSON.generate({message: 'uec lunch'})
    end

    get '/uec-lunch/nishishoku/:date' do
      get_nishishoku_menu(params[:date])
    end

    get '/uec-lunch/harmonia/:date' do
      get_harmonia_menu(params[:date])
    end

    helpers do
      def get_nishishoku_menu(date)
        result = NishishokuMenu.find_by_date(date)
        if result == nil
          fetch_nishishoku_menu(date)
          result = NishishokuMenu.find_by_date(date)
        end
        result.to_json(:except => [:id])
      end

      def get_harmonia_menu(date)
        result = HarmoniaMenu.find_by_date(date)
        if result == nil
          fetch_harmonia_menu(date)
          result = HarmoniaMenu.find_by_date(date)
        end
        result.to_json(:except => [:id])
      end

      def fetch_nishishoku_menu(date)
        menu_array = []
        f = open('http://www009.upp.so-net.ne.jp/harmonia/nishishoku/')
        html = f.read
        f.close

        doc = Nokogiri::HTML(html)
        tbody = doc.xpath('//table[@cellpadding="5"]/tr')
        date_row = tbody[0]
        date_row.xpath('td').each_with_index do |td, i|
          td_cont = td.content
          month = DateTime.parse(date).month
          day = DateTime.parse(date).day
          if /#{month}月\s*#{day}日/ =~ td_cont
            tbody.drop(1).each do |tr|
              menu_array.push(tr.xpath('td')[i].content)
            end
          end
        end
        menu = NishishokuMenu.new
        menu.date = date
        menu.a_set = menu_array[0]
        menu.b_set = menu_array[1]
        menu.higawari = menu_array[2]
        menu.save
      end

      def fetch_harmonia_menu(date)
        menu_array = []
        f = open('http://www009.upp.so-net.ne.jp/harmonia/')
        html = f.read
        f.close

        doc = Nokogiri::HTML(html)
        tbody = doc.xpath('//table[@cellpadding="5"]/tr')
        date_row = tbody[0]
        date_row.xpath('td').each_with_index do |td, i|
          td_cont = td.content
          month = DateTime.parse(date).month
          day = DateTime.parse(date).day
          if /#{month}月\s*#{day}日/ =~ td_cont
            tbody.drop(1).each do |tr|
              menu_array.push(tr.xpath('td')[i].content)
            end
          end
        end
        menu = HarmoniaMenu.new
        menu.date = date
        menu.special = menu_array[0]
        menu.higawari = menu_array[1]
        menu.osusume = menu_array[2]
        menu.s_lunch = menu_array[3]
        menu.noodle = menu_array[4]
        menu.s_dinner = menu_array[5]
        menu.save
      end
    end
  end
end