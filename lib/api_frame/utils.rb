module ApiFrame
	module Utils
		def self.url_escape(string)
			if !string.nil?
				CGI.escape(string.to_s)
			else
				raise TypeError, 'cannot escape nil'
			end
		end
		
		def self.call_proc_without_unknown_keywords(proc, *args, **kwargs, &block)
			params = proc.parameters.group_by(&:first).transform_values! do |m|
				m.map do |s|
					s[1]
				end
			end
			
			proc_keys =
				if params.key?(:keyrest)
					kwargs
				else
					kwargs.slice(*params.values_at(:key, :keyreq).compact.flatten)
				end
			
			proc.call(*args, **proc_keys, &block)
		end
		
		def self.request_type_from_method_argument(method)
			if method.instance_of?(Class) && method.ancestors.include?(Net::HTTPRequest)
				method
			else
				{
					get:  Net::HTTP::Get,
					post: Net::HTTP::Post,
				}.fetch(method)
			end
		end
	end
end
