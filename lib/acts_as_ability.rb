module Capable
  module ActsAsAbility

    def self.included(base)
      base.extend Capable::Base
      base.extend ClassMethods
    end

    module ClassMethods

      def acts_as_ability
        has_many :capabilities, :dependent => :destroy
        has_many :capables, :through => :capabilities

        include Capable::ActsAsAbility::InstanceMethods
      end

    end

    module InstanceMethods

      def assign_capable(capable, active=true, expires_at=nil, renewer=nil)
        Capability.create_capability(capable, self, active, expires_at, renewer)
      end

    end
  end
end
