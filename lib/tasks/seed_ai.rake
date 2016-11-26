namespace :seed_ai_players do
  task :basic_ai => :environment do
    params = {name: 'Basic AI', ai_type: 'Ais::BasicAi'}
    create_player(params)
  end

  task :advanced_ai => :environment do
    params = {name: 'Advanced AI', ai_type: 'Ais::AdvancedAi'}
    create_player(params)
  end

  task :create_all => :environment do
    ['basic_ai', 'advanced_ai'].each do |ai|
      Rake::Task["seed_ai_players:#{ai}"].execute
    end
  end

  task :delete_all => :environment do
    Player.where(computer: true).each do |ai|
      ai.destroy
    end
  end

  def create_player(params)
    params.merge!({computer: true})
    Player.where(params).first_or_create(params)
  end
end
