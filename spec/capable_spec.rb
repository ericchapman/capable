require 'spec_helper'

describe Capable do

  before do
    Ability.delete_all
    Capability.delete_all
    User.delete_all
    Renewer.delete_all
  end

  describe 'Capability Assignment' do
    let (:non_cached_user) { NonCachedUser.create(name:'Eric') }
    let (:user) { User.create(name:'Eric') }
    let (:admin_ability) { Ability.create(name: 'Admin Ability', description: 'Ability for admin', ability: 'admin') }
    let (:pro_ability) { Ability.create(name: 'Pro Ability', description: 'Ability for pro', ability: 'pro') }
    let (:renewer) { Renewer.create() }

    it 'Test Acts As Capable Instance Methods' do
      expect(user.has_ability?(admin_ability)).to eq false
      expect(user.has_ability?(admin_ability.ability)).to eq false

      # Test assigning ability
      user.assign_ability(admin_ability)
      user.reload

      expect(user.has_ability?(admin_ability)).to eq true
      expect(user.has_ability?(admin_ability.ability)).to eq true

      # Test unassigning ability
      user.unassign_ability(admin_ability)
      user.reload

      expect(user.has_ability?(admin_ability)).to eq false
      expect(user.has_ability?(admin_ability.ability)).to eq false
    end

    it 'Test Acts As Capable Instance Methods without array_list defined' do
      expect(non_cached_user.has_ability?(admin_ability)).to eq false
      expect(non_cached_user.has_ability?(admin_ability.ability)).to eq false

      # Test assigning ability
      non_cached_user.assign_ability(admin_ability)
      non_cached_user.reload

      expect(non_cached_user.has_ability?(admin_ability)).to eq true
      expect(non_cached_user.has_ability?(admin_ability.ability)).to eq true

      # Test unassigning ability
      non_cached_user.unassign_ability(admin_ability)
      non_cached_user.reload

      expect(non_cached_user.has_ability?(admin_ability)).to eq false
      expect(non_cached_user.has_ability?(admin_ability.ability)).to eq false
    end

    it 'Test Acts As Capability Renewer Instance Methods' do

      # Test create_capabilities works
      renewer.create_capabilities(user, [pro_ability, admin_ability], true, Time.now+4)
      user.reload

      expect(user.has_ability?(admin_ability)).to eq true
      expect(user.has_ability?(pro_ability)).to eq true

      Capability.expire_capabilities(Time.now+6)
      user.reload

      expect(user.has_ability?(admin_ability)).to eq false
      expect(user.has_ability?(pro_ability)).to eq false

      # Test renewing capabilities works
      renewer.renew_capabilities(Time.now+8)
      user.reload

      expect(user.has_ability?(admin_ability)).to eq true
      expect(user.has_ability?(pro_ability)).to eq true

      # Test expiration
      Capability.expire_capabilities(Time.now+10)
      user.reload

      expect(user.has_ability?(admin_ability)).to eq false
      expect(user.has_ability?(pro_ability)).to eq false

      # Test renewing capabilities does not work for the past
      renewer.renew_capabilities(Time.now-1)
      user.reload

      expect(user.has_ability?(admin_ability)).to eq false
      expect(user.has_ability?(pro_ability)).to eq false
    end


    it 'Test Acts As Capability Expiration Logic' do
      user.assign_ability(admin_ability)
      user.assign_ability(pro_ability, true, Time.now)
      user.reload

      expect(user.has_ability?(admin_ability)).to eq true
      expect(user.has_ability?(pro_ability)).to eq true

      # Test expiration
      Capability.expire_capabilities(Time.now+2)
      user.reload

      expect(user.has_ability?(admin_ability)).to eq true
      expect(user.has_ability?(pro_ability)).to eq false
    end

  end
end
