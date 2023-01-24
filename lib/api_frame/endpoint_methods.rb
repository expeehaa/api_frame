require 'cgi'
require 'json'
require 'net/https'

require_relative 'no_success_error'
require_relative 'utils'

module ApiFrame
	module EndpointMethods
		def base_uri
			raise NotImplementedError
		end
		
		def default_headers
			{}
		end
		
		def default_content_type
			'application/json'
		end
		
		def perform_request(method, api_path, query: nil, body: nil, headers: nil)
			uri = self.base_uri + api_path
			uri.query = URI.encode_www_form(query) if query
			
			Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
				ApiFrame::Utils.request_type_from_method_argument(method).new(uri).tap do |request|
					default_headers.merge(headers || {}).each do |name, value|
						request[name] = value
					end
					
					if body
						request['Content-Type'] = default_content_type
						request.body            = body
					end
				end.then do |request|
					http.request(request)
				end
			end
		end
		
		def self.included(klass)
			klass.extend(ClassMethods)
		end
		
		module ClassMethods
			def define_endpoint(name, method:, endpoint:, body: nil)
				define_method(name) do |*args, **kwargs|
					uri          = endpoint.respond_to?(:call) ? ApiFrame::Utils.call_proc_without_unknown_keywords(endpoint, *args, **kwargs) : endpoint
					request_body = body    .respond_to?(:call) ? ApiFrame::Utils.call_proc_without_unknown_keywords(body,     *args, **kwargs) : body
					
					perform_request(method, uri, body: request_body, query: kwargs.key?(:query) ? kwargs.fetch(:query) : nil, headers: kwargs.key?(:headers) ? kwargs.fetch(:headers) : nil).then do |response|
						if !kwargs.key?(:plain_response) || !kwargs.fetch(:plain_response)
							if response.is_a?(Net::HTTPSuccess)
								JSON.parse(response.body)
							else
								raise ApiFrame::NoSuccessError, response
							end
						else
							response
						end
					end
				end
			end
		end
	end
end
