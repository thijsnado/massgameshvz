
namespace :data do
  task :populate_test_data => :environment do
    Game.delete_all
    GameParticipation.delete_all
    User.delete_all(['username != ?', 'admin'])
    Event.delete_all
    LivingArea.delete_all
    game = Game.create(:signup_start_at => Time.now,
      :signup_end_at => Time.now + 3.days, 
      :start_at => Time.now + 1.day, 
      :end_at => Time.now + 7.days, 
      :time_per_food => 24.hours, 
      :bite_shares_per_food => 3
    )
    ['South West', 'North', 'Orchard Hill'].each do |living_area|
      LivingArea.create(:name => living_area)
    end
    living_areas = LivingArea.all
    zombies = Zombie.all
    humans = Human.all.reject{|h| h == Human::SQUAD}
    usernames = ['bob', 'jim', 'jill', 'mack', 'zack', 'hand_cock', 'keith_roods_p3|\|1s', 'foot_penis']
    username_seq = 0
    
    100.times do
      u = User.new :username => usernames[rand(usernames.size)] + username_seq.to_s, :password => 'test123'
      u.email_address = u.username + '@umass.edu'
      u.first_name = u.username
      u.last_name = 'Last'
      u.confirmed = true
      u.dont_send_confirmation = true
      u.save :validate => false
      gp = game.game_participations.new
      gp.user = u
      gp.living_area = living_areas[rand(living_areas.size)]
      creature_type = [zombies, humans][rand(2)]
      gp.creature = creature_type[rand(creature_type.size)]
      gp.save
      
      username_seq += 1  
    end
  end
end