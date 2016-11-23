FactoryGirl.define do
  factory :game do
    association :board, factory: :string_board
  end
end
