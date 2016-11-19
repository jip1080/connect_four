FactoryGirl.define do
  factory :game do
    association :board, factory: :board
  end
end
