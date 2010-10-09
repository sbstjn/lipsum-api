require 'rubygems'
require 'nokogiri'
require 'rest-client'

LIPSUM_URL = 'http://lipsum.com/feed/html'

module LipsumAPI

  def method_missing(method, *args)
    results = []
    if method.to_s =~ /^lipsum_(.*)/ 
      opts = (args.first.respond_to? :merge)?args.first: {}
      opts.merge!(:what => $1) if ["paragraphs", "lists", "words", "bytes"].include?($1)
      opts.merge!(:amount => self) if self.is_a?(Fixnum)
      plain_doc = perform_request opts
      doc = Nokogiri::HTML(plain_doc)
      doc.search('#lipsum p').each { |p|
         results << p.inner_text
      }
      results
    end
  end

  private
  def perform_request(opts)
    opts.merge!( :start => 'yes' ) if opts.delete( :start_with_lorem )
    begin
      RestClient.post LIPSUM_URL, opts
    rescue
      puts "some error with inet connection"
    end
  end

end

class Fixnum
  include LipsumAPI
end

puts 5.lipsum_words

puts 9.lipsum_words :start_with_lorem => true

puts 2.lipsum_paragraphs
