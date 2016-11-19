FactoryGirl.define do
  factory :game_player do
    association :player, factory: :player
    association :game, factory: :game
    sequence(:player_number) { |n| n }
  end
end
