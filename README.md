# Ruby gossiperl client

Ruby [gossiperl](https://github.com/radekg/gossiperl) client library.

## Installation

In your `Gemfile`:

    source 'http://rubygems.org/'
    gem 'gossiperl_client'

## Running

    require 'gossiperl_client'
    supervisor = ::Gossiperl::Client::Supervisor.new

## Connecting to an overlay

    supervisor.connect( :overlay_name  => :your_overlay_name
                        :overlay_port  => 6666,
                        :client_port   => 54321,
                        :client_name   => :your_client_name,
                        :client_secret => :your_client_secret,
                        :symkey        => :symmetric_key )

It's also possible to connect with a block:

    supervisor.connect( ... ) do |event|
      if event[:event] == :connected
        self.logger.info "Connected to overlay #{event[:options][:overlay_name]}..."
      elsif event[:event] == :disconnected
        self.logger.info "Disconnected from overlay #{event[:options][:overlay_name]}..."
      elsif event[:event] == :subscribed
        self.logger.info "Received subscription confirmation for #{event[:details][:types]}"
      elsif event[:event] == :unsubscribed
        self.logger.info "Received unsubscription confirmation for #{event[:details][:types]}"
      elsif event[:event] == :event
        self.logger.info "Received member related event #{event[:details][:type]} for member #{event[:details][:member]}."
      elsif event[:event] == :forwarded_ack
        self.logger.info "Received confirmation of forwarded message. Message ID: #{event[:details][:reply_id]}"
      elsif event[:event] == :forwarded
        self.logger.info "Received forwarded digest #{event[:digest]} of type #{event[:digest_type]}"
      elsif event[:event] == :failed
        self.logger.info "Received an error from the client. Reason: #{event[:error]}."
      end
    end

A client may be connected to multiple overlays.

## Subscribing / unsubscribing

Subscribing:

    supervisor.subscribe( :overlay_name, [ :event_1, :event_2, ... ] )

Unsubscribing:

    supervisor.unsubscribe( :overlay_name, [ :event_1, :event_2, ... ] )

Or in a block:

    self.subscribe( [ :event_1, :event_2, ... ] )
    self.unsubscribe( [ :event_1, :event_2, ... ] )

## Disconnecting from an overlay:

    supervisor.disconnect( :overlay_name )

Or in a block:

    self.stop

This will attempt a graceful exit from an overlay.

## Additional operations

### Checking current client state

    supervisor.state( :overlay_name )

Or in a block:

    self.current_state

### Get the list of current subscriptions

    supervisor.subscriptions( :overlay_name )

Or in a block:

    self.state.subscriptions

### Sending arbitrary digests


    supervisor.send( :overlay_name, :digestType, {
      :property => { :value => <value>, :type => <thrift-type-as-string>, :field_id => <field-order> }
    } )

Or in a block:

    self.send( :digestType, {
      :property => { :value => <value>, :type => <thrift-type-as-string>, :field_id => <field-order> }
    } )

Where `:type` is one of the supported Thrift types:

- `:bool`
- `:byte`
- `:double`
- `:i16`
- `:i32`
- `:i64`
- `:string`

And `:field_id` is a Thrift field ID.

## Running tests

    shindont tests

Tests assume an overlay with the details specified in the `tests/process_tests.rb` running.

## License

The MIT License (MIT)

Copyright (c) 2014 Radoslaw Gruchalski <radek@gruchalski.com>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
