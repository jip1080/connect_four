class Player < ActiveRecord::Base
  validates :name, presence: true
  
  has_many :game_players
  has_many :games, through: :game_players
  has_many :wins, class_name: 'Game', foreign_key: :winner_id
end
