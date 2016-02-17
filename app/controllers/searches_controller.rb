require 'open-uri'
# require 'hpricot'

class SearchesController < ApplicationController

  def index
    @searches = Search.all
  end

  def new
    @search = Search.new
  end

  def create
    url = "https://www.walmart.com/reviews/product/#{search_params[:product_id]}"
    key_words = search_params[:text].split(' ')
    doc = open(url) { |f| Hpricot(f) }
    

    page_count = doc.search(".paginator-list .js-pagination.link").last.inner_html.to_i

    counter = 0

    (1..page_count).each do |page|
       doc = open(url + "?page=#{page}") { |f| Hpricot(f) }

       doc.search(".js-review-list .customer-review .customer-review-text .js-customer-review-text").each do |text|
         
         match = true
         key_words.each do |word|
           if !text.inner_html.match(/\b(#{word})\b/i)
              match = false
              break
           end
         end
         counter += 1 if match 
       end 
    end

    redirect_to :root, notice: "Found #{counter} reviews"
  end

    private
    # Never trust parameters from the scary internet, only allow the white list through.
    def search_params
      params.require(:search).permit(:product_id, :text)
    end
end
