module Capable
  module ActsAsCapable

    def self.included(base)
      base.extend Capable::Base
      base.extend ClassMethods
    end

    module ClassMethods

      def acts_as_capable_3x
        has_many :capabilities, as: :capable, :dependent => :destroy
        has_many :abilities, :through => :capabilities, :conditions => 'capabilities.active = true'

        include Capable::ActsAsCapable::InstanceMethods
      end

      def acts_as_capable
        has_many :capabilities, as: :capable, :dependent => :destroy
        has_many :abilities, -> { where(capabilities: { active: true }) }, :through => :capabilities

        include Capable::ActsAsCapable::InstanceMethods
      end

    end

    module InstanceMethods

      def ability_array
        if self.respond_to? :ability_list
          if self.ability_list.present?
            return self.ability_list.split(",")
          else
            return Array.new
          end
        else
          puts "CAPABLE_WARNING: It is recommended to create the string 'ability_list' for the class '#{self.class.name}' in order to speed up ability checking" if Capable.configuration[:verbose]
          return self.abilities.pluck(:ability).uniq
        end
      end

      def has_ability?(ability)
        if ability.kind_of? String
          return ability_array.include? ability
        else
          return ability_array.include? ability.ability
        end
      end

      def assign_ability(ability, active=true, expires_at=nil, renewer=nil)
        Capability.create_capability(self, ability, active, expires_at, renewer)
      end

      def unassign_ability(ability, renewer=nil)
        Capability.where(capable: self, ability: ability, renewer: renewer, active: true).each do |capability|
          capability.active = false
          capability.save # This will kickoff the update logic
        end
      end

    end
  end
end


