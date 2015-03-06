module Capable
  module ActsAsCapability

    def self.included(base)
      base.extend Capable::Base
      base.extend ClassMethods
    end

    module ClassMethods

      def acts_as_capability
        belongs_to :ability
        belongs_to :capable, :polymorphic => true
        belongs_to :renewer, :polymorphic => true

        after_create :update_capables
        after_update :update_capables

        include Capable::ActsAsCapability::InstanceMethods
      end

      def create_capability(capable, ability, active=true, expires_at=nil, renewer=nil)
        create(
          capable: capable,
          ability: ability,
          active: active,
          expires_at: expires_at,
          renewer: renewer
        )
      end

      def expire_capabilities(expiration_date)
        self.where('expires_at is not null and expires_at < ? and active = ?', expiration_date, true).find_each do |capability|
          puts "CAPABILITY_EXPIRE: Capable #{capability.capable_type} (#{capability.capable_id}) expired the ability #{capability.ability.name}" if Capable.configuration[:verbose]
          capability.active = false
          capability.save!
        end
      end

    end

    module InstanceMethods

      def update_capables
        if self.capable.respond_to? :ability_list=
          self.capable.ability_list = self.capable.abilities.pluck(:ability).uniq.join(",")
          self.capable.save!
        else
          puts "CAPABILITY_ERROR: Accessor method 'ability_list' is not defined for the class '#{self.capable_type}'" if Capable.configuration[:verbose]
        end
      end

      def renew(expires_at)
        self.expires_at = expires_at
        self.active = (expires_at.nil? or expires_at > Time.now)
        self.save
      end

    end
  end
end
