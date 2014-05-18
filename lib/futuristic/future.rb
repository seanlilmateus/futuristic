motion_require './blank_slate'
motion_require './promise/promise'

module Dispatch # Future
  class Future < BlankSlate
    def initialize(promise = Promise.new, *args, &block)
      raise "Futures can't be initialized without blocks" unless ::Kernel.block_given?
      @promise = promise
      @group = Group.new
      @queue = Queue.new "de.mateus.futuristic.queue.#{@promise.object_id}"
      execute(*args, &block)
    end

    attr_reader :promise
    
    def wait(timeout=TIME_FOREVER)
      promise.send(:wait, timeout)
    end
    
    def value
      @promise.value
    end

    def inspect
      description.gsub(/Dispatch::Future/, "#{self.class} @state=#{promise.state}")      
    end
    
    def on_success(&block)
      self.promise.then(&block)
    end
    
    def on_failure(&block)
      self.promise.catch(&block)
    end
    
    def on_complete(&block)
      @group.notify(@queue) do
        ret = self.promise.value || self.promise.reason
        block.call(*ret) 
      end
    end

    private

    def execute(*args, &block)
      @queue.async(@group) do
        begin
          result = block.call(*args)
          @promise.fulfill(result)
        rescue => exception
          @promise.reject(exception)
        end
      end
    end
    
  end
end
