require 'sinatra/base'
require 'sinatra/reloader'
require 'json'
require 'nokogiri'
require 'open-uri'
require 'date'
require 'active_record'
module UECLunch
  class Application < Sinatra::Base
    Dir[File.dirname(__FILE__)+'/model/*.rb'].each {|f| require f}

    before do
      config = YAML.load_file('config.yml')['database']
      db = config[ENV['RACK_ENV'] || 'development']
      ActiveRecord::Base.establish_connection(db)
    end

    configure :development do
      register Sinatra::Reloader
    end

    not_found do
      JSON.generate({:errors => [{:message => 'Not found.', :code => 404}]})
    end

    get '/' do
      JSON.generate({message: 'It works!'})
    end

    get '/uec-lunch' do
      JSON.generate({message: 'uec lunch'})
    end

    get '/uec-lunch/nishishoku/:date/menu.json' do
      date = params[:date]
      if is_date_valid(date)
        get_menu('nishishoku', date){|d| NishishokuMenu.find_by_date(d)}
      else
        JSON.generate({:errors => [{:message => 'Invalid date.', :code => 400}]})
      end
    end

    get '/uec-lunch/harmonia/:date/menu.json' do
      date = params[:date]
      if is_date_valid(date)
        get_menu('harmonia', date){|d| HarmoniaMenu.find_by_date(d)}
      else
        JSON.generate({:errors => [{:message => 'Invalid date.', :code => 400}]})
      end
    end

    helpers do
      def is_date_valid(date)
        begin
          Date.strptime(str=date, format='%F')
          true
        rescue ArgumentError
          false
        end
      end

      def get_menu(kind, date, &block)
        result = block.call(date)
        if result == nil
          if store_menu(kind, date)
            result = block.call(date)
            result.to_json(:except => [:id])
          else
            JSON.generate({:errors => [{:message => 'No such entry.', :code => 404}]})
          end
        else
          result.to_json(:except => [:id])
        end
      end

      def store_menu(kind, date)
        if kind == 'nishishoku'
          store_nishishoku_menu(date)
        else
          store_harmonia_menu(date)
        end
      end

      def store_nishishoku_menu(date)
        html = fetch_html('http://www009.upp.so-net.ne.jp/harmonia/nishishoku/')
        menu_array =
          generate_menu_array(html, date)
        if menu_array.length != 0
          menu = NishishokuMenu.new
          menu.date = date
          menu.a_set = menu_array[0]
          menu.b_set = menu_array[1]
          menu.higawari = menu_array[2]
          menu.save
          true
        else
          false
        end
      end

      def store_harmonia_menu(date)
        html = fetch_html('http://www009.upp.so-net.ne.jp/harmonia/')
        menu_array =
          generate_menu_array(html, date)
        if menu_array.length != 0
          menu = HarmoniaMenu.new
          menu.date = date
          menu.special = menu_array[0]
          menu.higawari = menu_array[1]
          menu.osusume = menu_array[2]
          menu.s_lunch = menu_array[3]
          menu.noodle = menu_array[4]
          menu.s_dinner = menu_array[5]
          menu.save
          true
        else
          false
        end
      end

      def fetch_html(url)
        f = open(url)
        html = f.read
        f.close
        html
      end

      def generate_menu_array(html, date)
        menu_array = []
        doc = Nokogiri::HTML(html)
        tbody = doc.xpath('//table[@cellpadding="5"]/tr')
        date_row = tbody[0]
        date_row.xpath('td').each_with_index do |td, i|
          month = Date.parse(date).month
          day = Date.parse(date).day
          if /#{month}月\s*#{day}日/ =~ td.content
            tbody.drop(1).each do |tr|
              menu_array.push(tr.xpath('td')[i].content)
            end
          end
        end
        menu_array
      end
    end
  end
end
