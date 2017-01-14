require 'open-uri'
require 'nokogiri'

@to_file = []
@links = []

@page_count = 1 #счетчик страниц
@parsed_page = Nokogiri::HTML(open("http://www.asn-news.ru/news?page=#{@page_count}#all"))


puts "Какого числа смотрели последний раз? "
@user_date = gets.chomp.gsub(/[^0-9]/, " ").split(' ').map(&:to_i)
@user_date = Date.new(@user_date[2], @user_date[1], @user_date[0])

puts "Компания: "
@user_headers = gets.to_s.chomp #тут должны быть поисковые тэги

def search_news

  @parsed_page.css('#all').css('.other-item').each do |row|
    row.css('.date').each do |d|
      @news_date = d.to_s
      @news_date = Date.parse(@news_date)
    end

    @news_head = row.css('a').inner_text

    if @user_date <= @news_date && @news_head.include?(@user_headers)
      @news_link = row.css('a').first.attributes['href'].value
      @news_link = "http://www.asn-news.ru#{@news_link}"
      @links << @news_link
      @to_file << [[@news_date, @news_head, @news_link]]
    end
  end
end

@parsed_page.css('#all').css('.other-item').css('.date').each do |d|
  @news_date = d.to_s
  @news_date = Date.parse(@news_date)
end


while @user_date <= @news_date
  @parsed_page = Nokogiri::HTML(open("http://www.asn-news.ru/news?page=#{@page_count}#all"))
  search_news
  @page_count += 1
end



file = File.new("./#{@user_headers}.txt", "a:UTF-8")

@links.each do |link|
  news = Nokogiri::HTML(open(link))

  date = news.css('.content').css('.date').text.strip
  date = Date.parse(date).strftime('%d.%m.%Y')

  head = news.css('.content').css('h1').text.strip
  text = news.css('.text').css('p').text.strip


  file.print("#{date}\n #{head}\n #{text}\n\n")
end
file.close
