class ContactResource < JSONAPI::Resource
  attributes :address

  has_many :phone_numbers
end