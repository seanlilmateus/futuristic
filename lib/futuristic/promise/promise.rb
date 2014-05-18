motion_require './callback'
motion_require './progress'

module Dispatch # Promise
  class Promise
    Error = Class.new(RuntimeError)

    include Progress

    attr_reader :state, :value, :reason, :backtrace

    def initialize
      @state = :pending
      @callbacks = []
      @semaphore = Semaphore.new 0
    end

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
      next_promise = Promise.new

      add_callback { Callback.new(self, on_fulfill, on_reject, next_promise) }
      next_promise
    end

    def catch(&block)
      self.then(nil, block.to_proc)
    end

    def add_callback(&generator)
      if pending?
        @callbacks << generator
      else
        dispatch!(generator.call)
      end
    end

    def sync
      wait if pending?
      raise reason if rejected?
      value
    end

    def fulfill(value = nil, backtrace = nil)
      dispatch(backtrace) do
        @state = :fulfilled
        @value = value
      end
    end

    def reject(reason = nil, backtrace = nil)
      dispatch(backtrace) do
        @state = :rejected
        @reason = reason || Error
      end
    end

    def dispatch(backtrace)
      if pending?
        yield
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
    
    private
    
    def wait(time_out=Dispatch::TIME_FOREVER)
      @semaphore.wait(time_out) if pending?
    end
  end
end