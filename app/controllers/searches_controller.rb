require 'open-uri'

class SearchesController < ApplicationController

  def index
    if session[:show]
      search = Search.last
      @found_reviews = search.reviews if search    
    end
    session[:show] = false
  end

  def new
    @search = Search.new
  end

  def create
    url = "https://www.walmart.com/reviews/product/#{search_params[:product_id]}"
    key_words = search_params[:text].split(' ')
    doc = open(url) { |f| Hpricot(f) }
    
    last_page_node = doc.search(".paginator-list .js-pagination.link").last
    page_count = last_page_node ? last_page_node.inner_html.to_i : 1

    counter = 0
    items = []

    @search = Search.create(search_params)

    (1..page_count).each do |page|
       doc = open(url + "?page=#{page}") { |f| Hpricot(f) }

       doc.search(".js-review-list .customer-review").each do |review|
         
        text = review.search(".customer-review-body .customer-review-text").first.inner_html

         match = true
         key_words.each do |word|
           if !text.inner_html.match(/\b(#{word})\b/i)
              match = false
              break
           end
         end

         if match 
            counter += 1
            date = review.search(".customer-review-body .customer-review-date").first.inner_html 
            nick = review.search(".customer-review-body .js-nick-name").first.inner_html 
            title = review.search(".customer-review-body .customer-review-title").first.inner_html             

            @search.reviews << Review.create(title: title, nick: nick, date: date, text: text)            
         end
       end 
    end
    session[:show] = true
    redirect_to :root, notice: "Found #{counter} reviews"
  end

    private
    # Never trust parameters from the scary internet, only allow the white list through.
    def search_params
      params.require(:search).permit(:product_id, :text)
    end
end
