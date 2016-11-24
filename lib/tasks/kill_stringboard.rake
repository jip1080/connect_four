namespace :boards do
  task :delete_stringboards => :environment do
    boards = Boards::StringBoard.all
    boards.each do |board|
      g = board.game
      if(g)
        g.game_players.each do |gp|
          gp.destroy
        end
        g.destroy
      end
      board.destroy
    end
  end
end
