# Capable

This Gem works similar to UNIX group permissions.  The server defines different 'abilities' that can then be applied to *capable* objects via a *capabilities* join table.  The *capabilities* table also allows expiration dates to be defined and applies the concept of *renewer*'s where another object can renew the expiration date of the *capability*.

This scheme was originally developed to provide purchasable features in an APP via In App Purchase that would renew based on subscriptions.  The *User* is the *capable* object and the *Receipt* is the renewer.  If a receipt renews, it has the ability to update the *capabilities* for the *User*

One good feature about this class is if a user has a certain ability from 2 different sources, if one of them expires or is deleted, the user will still have the ability from the other source.  For example

 - User purchases [pro, gold] abilities.  User is now [pro, gold]
 - User purchases [sponsor, gold] abilities.  User is now [sponsor, pro, gold]
 - User expires [pro, gold] abilities.  User is now [sponsor, gold]

This *ability* scheme can be applied to any object in the database by using the *acts_as_capable* method.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'capable'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install capable

## Usage

### Setup Database Schema

Run the following code to create the *Ability* and *Capability* models and migration file.

    $ rails generate capable

In order to activate the local caching features of this Gem, you will need to add the following to your migration file for each class you are going to declare as *capable*.

```ruby
add_column :<capable class>, :ability_list, :string
```

**If you do not add the above attribute to all of your *capable* objects, the system will query for the abilities EVERY TIME you call *ability_array* on a *capable* object.**  Once complete, migrate the database by running

    $ rake db:migrate

### Configuration

To set different configuration options, create the file "config/initializers/capable.rb" with the following code (currently you can only turn on 'verbose')

```ruby
require 'capable'

Capable.configure do |config|
  config.verbose = true
end
```

### Ability

The *Ability* class provides a way for the admin to create different abilities that can be assigned to *capable* objects.  It has the following instance methods

```ruby
# This will assign an ability to a capable object via the capability class (the options in []'s are optional)
ability.assign_capable(capable, [active=true, expires_at=nil, renewer=nil])
```

### Capability

The *Capability* class is what ties the *abilities* to *capable* objects.  It also has a *renewer* hook that provides a way for something to periodically renew the expiration date.  Another cool feature of this class is that when updated, it will automatically re-initialize the *ability_list* of the *capable* object if it is defined.  Here are it's methods

```ruby
# Create a capability (the options in []'s are optional)
Capability.create_capability(capable, ability, [active=true, expires_at=nil, renewer=nil])

# Expires all capabilities that have an expiration date that is not nil and is older than the passed in date (sets active to false).  This will automatically update the abilities of the corresponding capable object
Capability.expire_capabilities(expiration_date)

# Renew the capability
capability.renew(expires_at)
```

### Acts As Capable

For each class that you would like to assign *abilities* to, do the following in your class.  For this example, we will use the class *User*.

```ruby
require 'capable'

class User < ActiveRecord::Base
  acts_as_capable # Rails 4
  # note for Rails <= 3.x, you need to use 'acts_as_capable_3x'
end
```

Also note from above that you will want to create a string called *ability_list* on the class to allow for local caching of abilities in the *capable* object.  This is all handled automatically by the Gem when a capability is updated.

Once an object is declared as *capable* it allows the following methods to be defined

```ruby
# See if the user has a certain ability.  Note that 'ability' can either be an ability object OR the 'ability' string attribute of an ability object
user.has_ability?(ability)

# Return a comma delimited list of strings of the different abilities.  This is useful for example when serializing the object over an API.  The mobile client can simply work off of this array.
user.ability_array

# Assign an ability to a user (the options in []'s are optional)
user.assign_ability(ability, [active=true, expires_at=nil, renewer=nil])

# Unassign an ability from a user (just sets active to false.  The options in []'s are optional)
user.unassign_ability(ability, [renewer=nil])
```
### Acts As Capability Renewer

A *capability renewer* is a class that can renew the expiration date of capabilities such as a subscription.  To create these classes do the following

```ruby
require 'capable'

class Renewer < ActiveRecord::Base
  acts_as_capability_renewer
end
```

Once an object is declared as a capability renewer, it has the following instance methods available to it

```ruby
# Create capabilities for a capable object with this as the renewer.  This will only create the capabilities if capable is not nil, the abilities array has values, and the current count of the capabilities is 0
renewer.create_capabilities(capable, abilities, active, expires_at)

# Renew the expiration date for the capabilities of a renewer (note that this sets active attribute based on the current date so if it is in the past, active will be set to 'false')
renewer.renew_capabilities(expires_at)
```

The renewer concept allows a capability to be renewed when the expiration date is updated.  This is good for example when a user purchases more time on a role.

## Contributing

1. Fork it ( https://github.com/[my-github-username]/capable/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

> Written with [StackEdit](https://stackedit.io/).