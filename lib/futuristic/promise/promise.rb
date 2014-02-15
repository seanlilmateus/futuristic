motion_require './callback'
motion_require './progress'

module Dispatch # Promise
  class Promise

    Error = Class.new(RuntimeError)

    include Progress

    def initialize
      @state = :pending
      @semaphore = Dispatch::Semaphore.new 0
      @callbacks = []
    end

    attr_reader :state, :value, :reason, :backtrace

    def pending?
      @state == :pending
    end

    def fulfilled?
      @state == :fulfilled
    end

    def rejected?
      @state == :rejected
    end

    def then(on_fulfill = nil, on_reject = nil, &block)
      on_fulfill ||= block
      next_promise = Dispatch::Promise.new

      add_callback { Callback.new(self, on_fulfill, on_reject, next_promise) }
      next_promise
    end

    def add_callback(&generator)
      if pending?
        @callbacks << generator
      else
        dispatch!(generator.call)
      end
    end

    def sync(time_out=Dispatch::TIME_FOREVER)
      @semaphore.wait(time_out) if pending?
      raise reason if rejected?
      value
    end

    def fulfill(value = nil, backtrace = nil)
      dispatch(backtrace) do
        willChangeValueForKey('value')
        @value = value
        didChangeValueForKey('value')
        change_state_to :fulfilled
      end
    end

    def reject(reason = nil, backtrace = nil)
      dispatch(backtrace) do
        change_state_to :rejected
        willChangeValueForKey('reason')
        @reason = reason || Error
        didChangeValueForKey('reason')
      end
    end

    def dispatch(backtrace, &block)
      if pending?
        block.call
        @backtrace = backtrace || caller
        @callbacks.each { |generator| dispatch!(generator.call) }
      end
    ensure
      @semaphore.signal
      nil
    end

    def dispatch!(callback)
      defer { callback.dispatch }
    end

    def defer
      yield
    end

    def inspect
      description.gsub(/Dispatch::Promise/, "#{self.class} @state=#{self.state}")
    end

    private

    def change_state_to(new_state)
      willChangeValueForKey('state')
      @state = new_state
      didChangeValueForKey('state')
    end
  end
end