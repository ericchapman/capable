module Capable
  module ActsAsCapabilityRenewer

    def self.included(base)
      base.extend Capable::Base
      base.extend ClassMethods
    end

    module ClassMethods

      def acts_as_capability_renewer
        has_many :capabilities, as: :renewer, :dependent => :destroy

        include Capable::ActsAsCapabilityRenewer::InstanceMethods
      end

    end

    module InstanceMethods

      def create_capabilities(capable, abilities, active, expires_at)
        if capable.present? and abilities.present? and self.capabilities.count == 0
          abilities.each do |ability|
            Capability.create_capability(capable, ability, active, expires_at, self)
          end
        end
      end

      def renew_capabilities(expires_at)
        self.capabilities.each do |capability|
          capability.renew(expires_at)
        end
      end

    end

  end
end

