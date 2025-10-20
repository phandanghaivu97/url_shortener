FactoryBot.define do
  factory :phone_number do
    contact
    number { Faker::PhoneNumber.phone_number }
  end
end
