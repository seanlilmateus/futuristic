motion_require './promise/promise'

module Dispatch # Channel
  class Channel
    def initialize
      @queue = Atomic.new([])
      @pending = Atomic.new([])
    end
    
    def recv
      if @queue.empty?
        promise = Promise.new
        @pending << @promise
      else
        promise = @queue.shift
        promise
      end
      promise.sync
    end

    def take
      if @queue.empty?
        promise = Promise.new
        @pending << promise
      else
        promise = @queue.shift
      end
      promise
    end
    # alias recv take

    def put(value)
      if @pending.empty?
        promise = Promise.new
        @queue << promise.fulfill(value)
      else
        promise = @pending.shift
        promise.fulfill(value)
      end
      promise
    end
    # alias << put

    def drain(error)
      until @queue.empty?
        promise = @queue.pop
        promise.reject(error)
      end

      until @pending.empty?
        promise = @pending.pop
        promise.reject(error)
      end
      self
    end
  end
end