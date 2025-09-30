class UserResource < JSONAPI::Resource
  attributes :email, :first_name, :last_name

  has_many :contacts
end
