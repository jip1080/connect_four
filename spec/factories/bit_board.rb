FactoryGirl.define do
  factory :bit_board, class: Boards::BitBoard do
    rows 6
    columns 7
  end
end
