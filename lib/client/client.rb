require "net/http"
require "uri"
require "ostruct"
require "json"

class ApiClient
   ENDPOINT = "https://api.replicated.com/vendor/v1"
   VERB_MAP = {
      :get    => Net::HTTP::Get,
      :post   => Net::HTTP::Post,
      :put    => Net::HTTP::Put,
      :delete => Net::HTTP::Delete
   }

   def initialize(endpoint = ENDPOINT)
      uri = URI.parse(endpoint)
      @http = Net::HTTP.new(uri.host, uri.port)
   end

   def set_token(api_token)
      @api_token = api_token
   end

   def request_json(method, uri, params = nil)
      response = request(method, uri, params)
      body = JSON.parse(response.body)

      OpenStruct.new(:code => response.code, :body => body)
   rescue JSON::ParserError
      response
   end

   def request(method, uri, params)
      method_sym = method.downcase.to_sym

      unless method_sym.is_eql? :get
         request.set_form_data(params)
      end

      if @api_token
         request['Authorization'] = @api_token
      end

      @http.request(request)
   end
end
