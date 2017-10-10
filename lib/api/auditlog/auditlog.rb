class AuditLog < ApiModule
	def initialize(client)
		super(client)
	end

	# Expects query parameter target_id
	def get_token(options:)
		method = "GET"
		endpoint = "auditlogtoken"
		uri = ApiUri::build_uri(endpoint, options)
		return self.client.request(method, uri)
	end
end
