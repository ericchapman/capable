require "acts_as_ability"
require "acts_as_capability"
require "acts_as_capable"
require "acts_as_capability_renewer"
require "capable/version"
require 'capable/configuration'
require 'capable/base'
require 'active_record'

module Capable

  class << self

    # An Capable::Configuration object. Must act like a hash and return sensible
    # values for all Capable::Configuration::OPTIONS. See Capable::Configuration.
    attr_writer :configuration

    # Call this method to modify defaults in your initializers.
    #
    # @example
    #   Capable.configure do |config|
    #     config.<attr> = <value>
    #   end
    def configure
      yield(configuration)
    end

    # The configuration object.
    # @see Capable::Configuration
    def configuration
      @configuration ||= Configuration.new
    end
  end

end

ActiveRecord::Base.send(:include, Capable::ActsAsAbility)
ActiveRecord::Base.send(:include, Capable::ActsAsCapability)
ActiveRecord::Base.send(:include, Capable::ActsAsCapable)
ActiveRecord::Base.send(:include, Capable::ActsAsCapabilityRenewer)
