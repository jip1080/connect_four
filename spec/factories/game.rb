FactoryGirl.define do
  factory :game do
    association :board, factory: :bit_board
  end
end
