# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
# Environment variables (ENV['...']) are set in the file config/application.yml.
# See http://railsapps.github.com/rails-environment-variables.html
puts 'ROLES'
YAML.load(ENV['ROLES']).each do |role|
  Role.find_or_create_by_name({ :name => role }, :without_protection => true)
  puts 'role: ' << role
end
puts 'DEFAULT USERS'
user = User.find_or_create_by_email :name => ENV['ADMIN_NAME'].dup, :email => ENV['ADMIN_EMAIL'].dup, :password => ENV['ADMIN_PASSWORD'].dup, :password_confirmation => ENV['ADMIN_PASSWORD'].dup
puts 'user: ' << user.name
user.add_role :admin

{
    Team::MIDWEST => [
        'Louisville',
        'Duke',
        'Michigan St',
        'St Louis',
        'Oklahoma St',
        'Memphis',
        'Creighton',
        'Colorado St',
        'Missouri',
        'Cincinnati',
        'Play-In MW11',
        'Oregon',
        'New Mex St',
        'Valparaiso',
        'Albany',
        'Play-In MW16'
    ],
    Team::WEST => [
        'Gonzaga',
        'Ohio St',
        'New Mexico',
        'Kansas St',
        'Wisconsin',
        'Arizona',
        'Notre Dame',
        'Pittsburgh',
        'Wichita St',
        'Iowa St',
        'Belmont',
        'Ole Miss',
        'Play-In W13',
        'Harvard',
        'Iona',
        'Southern U'
    ],
    Team::SOUTH => [
        'Kansas',
        'Georgetown',
        'Florida',
        'Michigan',
        'VCU',
        'UCLA',
        'San Diego St',
        'N Carolina',
        'Villanova',
        'Oklahoma',
        'Minnesota',
        'Akron',
        'S Dakota St',
        'NW State',
        'Fla Gulf Coast',
        'W Kentucky'
    ],
    Team::EAST => [
        'Indiana',
        'Miami (FL)',
        'Marquette',
        'Syracuse',
        'UNLV',
        'Butler',
        'Illinois',
        'NC State',
        'Temple',
        'Colorado',
        'Bucknell',
        'California',
        'Montana',
        'Davidson',
        'Pacific',
        'Play-In E16'
    ]
}.each do |region, team_names|
  team_names.each_with_index do |name, i|
    Team.create :region => region, :seed => i+1, :name => name
  end
end

Team::REGIONS.each do |region|
  #64 teams
  i, j = 1, 16
  while i < j
    team_one = Team.find_by_region_and_seed(region, i)
    team_two = Team.find_by_region_and_seed(region, j)
    Game.create :team_one => team_one, :team_two => team_two
    i += 1
    j -= 1
  end

  #32 teams
  [[1,8], [5,4], [6,3], [7,2]].each do |one, two|
    game_one = Game.find_by_team_one_id(Team.find_by_region_and_seed(region, one))
    game_two = Game.find_by_team_one_id(Team.find_by_region_and_seed(region, two))
    Game.create :game_one => game_one, :game_two => game_two
  end

  #Sweet 16
  [[1,5], [6, 7]].each do |one, two|
    game_one = Game.find_by_team_one_id(Team.find_by_region_and_seed(region, one)).next_game
    game_two = Game.find_by_team_one_id(Team.find_by_region_and_seed(region, two)).next_game
    Game.create :game_one => game_one, :game_two => game_two
  end

  #Great 8
  game_one = Game.find_by_team_one_id(Team.find_by_region_and_seed(region, 1)).next_game.next_game
  game_two = Game.find_by_team_one_id(Team.find_by_region_and_seed(region, 6)).next_game.next_game
  Game.create :game_one => game_one, :game_two => game_two
end

#Final 4
game_one = Game.find_by_team_one_id(Team.find_by_region_and_seed(Team::MIDWEST, 1)).next_game.next_game.next_game
game_two = Game.find_by_team_one_id(Team.find_by_region_and_seed(Team::WEST, 1)).next_game.next_game.next_game
champ_one = Game.create :game_one => game_one, :game_two => game_two

game_one = Game.find_by_team_one_id(Team.find_by_region_and_seed(Team::SOUTH, 1)).next_game.next_game.next_game
game_two = Game.find_by_team_one_id(Team.find_by_region_and_seed(Team::EAST, 1)).next_game.next_game.next_game
champ_two = Game.create :game_one => game_one, :game_two => game_two

#Championship
Game.create :game_one => champ_one, :game_two => champ_two
