
require 'ffaker'

FactoryBot.define do
  factory :user do

  	email {FFaker::Internet.email }
  	password {'123987'}
  	password_confirmation {'123987'}
  end
end
