module MyApi
  class Base < JsonApiClient::Resource
    self.site = "http://localhost:3000"
  end
end
