FactoryBot.define do
  factory :contact do
    user
    address { Faker::Address.full_address }
  end
end
