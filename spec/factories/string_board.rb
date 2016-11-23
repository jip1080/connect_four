FactoryGirl.define do
  factory :string_board, class: Boards::StringBoard do
    rows 6
    columns 7
  end
end
