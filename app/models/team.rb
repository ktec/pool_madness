class Team < ActiveRecord::Base
  SOUTH = 'South'
  WEST = 'West'
  EAST = 'East'
  MIDWEST = 'Midwest'

  REGIONS = [SOUTH, WEST, EAST, MIDWEST]

  attr_accessible :region, :seed, :name

  validates :name, :uniqueness => true, :length => {:maximum => 15}

  validates :region, :inclusion => {:in => [SOUTH, WEST, EAST, MIDWEST]}

  validates :seed,
            :numericality => { :only_integer => true, :greater_than_or_equal_to => 1, :less_than_or_equal_to => 16 },
            :uniqueness => { :scope => :region }


  def first_game
    Game.find_by_team_one_id(self.id) || Game.find_by_team_two_id(self.id)
  end
end