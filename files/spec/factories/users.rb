FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { SecureRandom.uuid }
    password_confirmation { password }
  end
end
