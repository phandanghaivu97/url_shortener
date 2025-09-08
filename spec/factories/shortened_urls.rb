FactoryBot.define do
  factory :consultation do
    user
    assignment_type { :selectable }
    status { :draft }
    visibility_policy { :public }
    advisor_policy { :open }
    is_anonymous { false }
    organization { user.organization }
    title { Faker::Lorem.sentence(word_count: 3) }
    content { Faker::Lorem.paragraph(sentence_count: 1) }
    additional_information { Faker::Lorem.sentence(word_count: 5) }
    knowledge { Faker::Lorem.sentence(word_count: 10) }
    contact_method_ids { [1, 2, 3] }
    duration { 60 } # in minutes
    start_at { Time.current }
    end_at { Time.current + 1.hour }
    initial_message { Faker::Lorem.sentence(word_count: 5) }
    
end
