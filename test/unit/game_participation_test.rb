require 'test_helper'

class GameParticipationTest < ActiveSupport::TestCase
  
  #The most likely scenario, a zombie bites a human
  test "zombie can bite human" do 
    zombie_participation = game_participations(:zombie_participation)
    human_participation = game_participations(:human_participation)
  
    assert human_participation.is_human?
    assert zombie_participation.is_zombie?
  
    assert_difference 'BiteEvent.count' do
      zombie_participation.report_bite human_participation
    end
    
    human_participation = GameParticipation.find(human_participation.id)
  
    assert human_participation.is_zombie?
  end
  
  #sometimes zombies are slow to report there bite so humans become self bitten
  #we want to make sure they get credit when the reporting happens
  test "zombie can bite self bitten zombie" do 
    zombie_participation = game_participations(:zombie_participation)
    self_bitten_zombie_participation = game_participations(:self_bitten_zombie_participation)
    
    assert self_bitten_zombie_participation.is_zombie?
    assert self_bitten_zombie_participation.current_parent != zombie_participation
    
    assert_no_difference 'BiteEvent.count' do
      zombie_participation.report_bite self_bitten_zombie_participation
    end
    
    self_bitten_zombie_participation = GameParticipation.find(self_bitten_zombie_participation.id)
    zombie_participation = GameParticipation.find(zombie_participation.id)
    
    assert_equal self_bitten_zombie_participation.current_parent, zombie_participation
  end
  
  #we need to make sure that a zombie cannot get credit
  #for biting non self bitten zombies
  test "zombie cannot bite non self bitten zombies" do
    zombie_participation = game_participations(:zombie_participation)
    immortal_zombie_participation = game_participations(:immortal_zombie_participation)
    
    assert !zombie_participation.report_bite(immortal_zombie_participation)
  end
  
  #a human cannot bite a human
  test "human cannot bite human" do
    human_participation = game_participations(:unreported_participation)
    victom_participation = game_participations(:human_participation)
    
    assert !human_participation.report_bite(victom_participation)
  end
  
  test "human can be bitten zombie" do
    human_participation = game_participations(:human_participation)
    zombie_participation = game_participations(:zombie_participation)
    
    assert human_participation.is_human?
    assert zombie_participation.is_zombie?
    
    assert_difference 'BiteEvent.count' do
      human_participation.report_bitten zombie_participation
    end
    
    human_participation = GameParticipation.find(human_participation.id)
    zombie_participation = GameParticipation.find(zombie_participation.id)
    
    assert human_participation.is_zombie?
  end
  
  test "human can be bitten by human" do
    human_participation = game_participations(:human_participation)
    unreported_participation = game_participations(:unreported_participation)
    
    assert human_participation.is_human?
    assert unreported_participation.is_human?
  
    assert_difference 'BiteEvent.count' do
      human_participation.report_bitten unreported_participation
    end
    
    human_participation = GameParticipation.find(human_participation.id)
  
    assert human_participation.is_zombie?
  end
end
