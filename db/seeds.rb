DatabaseCleaner.clean_with :truncation

user = User.create_with(name: ENV['ADMIN_NAME'].dup, password: ENV['ADMIN_PASSWORD'].dup, password_confirmation: ENV['ADMIN_PASSWORD'].dup).find_or_create_by(email: ENV['ADMIN_EMAIL'].dup)
user.admin!
puts "admin user: #{user.name}"

FactoryGirl.create(:tournament, :completed, name: "Completed Tourney")
FactoryGirl.create(:tournament, :with_first_two_rounds_completed, name: "Two Rounds Completed Tourney")
FactoryGirl.create(:tournament, :not_started, name: "Unstarted Tourney")

Tournament.all.each do |tournament|
  puts "creating 2 pools for tournament #{tournament.id}"
  FactoryGirl.create_list(:pool, 2, tournament: tournament)
end

Pool.all.each do |pool|
  puts "creating admin for pool #{pool.id}"
  pool_user = FactoryGirl.create(:pool_user, pool: pool)
  pool_user.admin!

  puts "createing 5 regular users for pool #{pool.id}"
  FactoryGirl.create_list(:pool_user, 5, pool: pool)

  pool.users.each do |user|
    puts "creating a completed bracket for pool/user #{pool.id}/#{user.id}"
    FactoryGirl.create(:bracket, :completed, user: user, pool: pool)
  end
end

Bracket.all.each { |b| b.paid! }

puts "updating pool-admin and user email addresses"
PoolUser.admin.first.user.update!(email: "pool-admin@pool-madness.com")

user = PoolUser.regular.first.user

user.update!(email: "user@pool-madness.com")

puts "creating unpaid brackets"

FactoryGirl.create_list(:bracket, 2, :completed, user: user, pool: user.pools.first)

Bracket.find_each do |bracket|
  bracket.calculate_points
  bracket.calculate_possible_points
end