FactoryBot.define do
  factory :user do
    email { Faker::Internet.unique.email }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    encrypted_password { Faker::Internet.password(min_length: 8) }
  end
end
