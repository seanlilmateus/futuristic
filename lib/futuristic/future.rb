motion_require './promise/promise'

module Dispatch # Future
  class Future

    def self.reduce(*futures, &block)
      raise 'block not given' unless block_given?
      promise = Promise.new
      Dispatch::Queue.concurrent(:high).async do
        futures = futures.flatten
        result = block.(*futures.map(&:value))
        promise.fulfill(result)
      end
      promise
    end

    def initialize(*args, &block)
      @promise = Promise.new
      execute(*args, &block)
    end

    attr_reader :promise

    def method_missing(meth, *args, &blk)
      promise.send(meth, *args, &blk)
    end

    def execute(*args, &block)
      queue = Queue.new "de.mateus.future.queue.#{object_id}"
      queue.async do
        begin
          result = block.call(*args)
          @promise.fulfill(result)
        rescue Exception => exception
          @promise.reject(exception)
        end
      end
    end
    
    def value(timeout=Dispatch::TIME_FOREVER)
      @promise.sync(timeout)
    end

    def inspect
      description.gsub(/Dispatch::Future/, "#{self.class} @state=#{self.state}")
    end

  end
end