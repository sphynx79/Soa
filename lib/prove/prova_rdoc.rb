class Ciao
   #
   # Creates a Watir::Browser instance and goes to URL.
   #
   # @example
   #   browser = Watir::Browser.start "www.google.com", :chrome
   #   #=> #<Watir::Browser:0x..fa45a499cb41e1752 url="http://www.google.com" title="Google">
   #
   # @param [String] url
   # @param [Symbol, Selenium::WebDriver] browser :firefox, :ie, :chrome, :remote or Selenium::WebDriver instance
   # @return [Watir::Browser]
   #
   def start(url, browser = :firefox, *args)
      b = new(browser, *args)
      b.goto url

      b
   end
end
class MyWebServer
  # Handles a request
  # @param request [Request] the request object
  # @return [String] the resulting webpage
  def get(request) "hello" end

  # (see #get)
  def post(request) "hello" end
end
