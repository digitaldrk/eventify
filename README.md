[![Build Status](https://travis-ci.org/smakagon/eventify.svg?branch=master)](https://travis-ci.org/smakagon/eventify)

# Eventify

Client for Eventify. Allows to publish events from Ruby-applications.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'eventify'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install eventify

## Usage
___
### Getting Started:
This guide assumes you have created an account and obtained an API key from Eventify.

Somewhere in your app you will need to instantiate the Eventify client like this: `Eventify::Client.new(api_key: your_api_key)`. Where and how you instantiate the client may differ depending on your project but in a basic rails application for example, one option is to first enable loading of the lib directory your application.rb file:

config/application.rb
```
module YourApp
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.autoload_paths << Rails.root.join('lib')
  end
end
```

Create a file in your project's lib directory and add this to the new file you created:

lib/eventify.rb
```
class Eventify
  def self.client
    @client ||= Eventify::Client.new(api_key: 'your_eventify_api_key')
  end

  def self.publish(event, data)
    client.publish(event, data)
  end
end
```
Great, now all you have to do is add:

 `Eventify.publish('type': 'Event Type String', 'data': {'data key': 'data value'})`

'type': Where you see `Event Type String` is where you place the name of the event, use something that is specific to the event and easy to understand.

'data': Where you see `data_key` and `data value` will be the key and value pertaining to the event type.
___
### Example:
```
class OrdersController < ApplicationController
  def create
    @order = Order.new(params[:order])

    respond_to do |format|
     if @order.save
       format.html  { redirect_to(@order,
                     :notice => 'Post was successfully created.') }
       format.json  { render :json => @order,
                     :status => :created, :location => @order }
     else
       format.html  { render :action => "new" }
       format.json  { render :json => @order.errors,
                     :status => :unprocessable_entity }

       Eventify.publish('type': 'Order Failure',
                        'data': {
                          'params': params.to_s,
                          'Error Message(s)':
                          @order.errors.to_s
                        })
     end
   end
  end
end
```
___
## Options
* `logger:`
  * logger does stuff

Example:
```
def self.client
  @client ||= Eventify::Client.new(api_key: your_eventify_api_key, logger: 'foo')
end
```

Example:
* `raise_error:`
  * By default, Eventify will swallow errors, return `true`, and proceed as if nothing happened but perhaps you need or want to exit and return an Exception. Add `raise_error: true` to the client method.

Example:
```
def self.client
  @client ||= Eventify::Client.new(api_key: your_eventify_api_key, raise_error: true)
end
```
## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Eventify project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/smakagon/eventify/blob/master/CODE_OF_CONDUCT.md).
