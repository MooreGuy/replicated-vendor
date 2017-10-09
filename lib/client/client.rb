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

   def request_json(method, path, params)
      response = request(method, path, params)
      body = JSON.parse(response.body)

      OpenStruct.new(:code => response.code, :body => body)
   rescue JSON::ParserError
      response
   end

   def request(method, path, params)
      method_sym = method.downcase.to_sym
      case method_sym
      when :get
         full_path = encode_path_params(path, params)
         request = VERB_MAP[method_sym].new(full_path)
      else
         request = VERB_MAP[method_sym].new(path)
         request.set_form_data(params)
      end

      if @api_token
         request['Authorization'] = @api_token
      end

      @http.request(request)
   end
      
   def encode_path_params(path, params)
      encoded = URI.encode_www_form(params)
      [path, encoded].join("?")
   end
end
