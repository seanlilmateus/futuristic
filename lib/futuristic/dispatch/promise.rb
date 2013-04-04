module Dispatch
  class Promise < BasicObject
    # new :: a -> Promise b
    # MacRuby and Rubymotion BasicObject#initialize doesn't like blocks, so we have to do this
    def self.new(&block)
      unless block_given?
        ::Kernel.raise(::ArgumentError, "You cannot initalize a Dispatch::Promise without a block")
      end
      self.alloc.initialization(block)
    end


    # setup Grand Central Dispatch concurrent Queue and Group
    def initialization(block)
      init
      @computation = block
      # Groups are just simple layers on top of semaphores.
      @group = ::Dispatch::Group.new
      # Each thread gets its own FIFO queue upon which we will dispatch
      # the delayed computation passed in the &block variable.
      @promise_queue = ::Dispatch::Queue.concurrent("org.macruby.#{self.class}-0x#{hash.to_s(16)}") #
      self
    end


    def inspect
      __value__.inspect
    end


    private
    # Asynchronously dispatch the future to the thread-local queue.
    def __force__
      @running = true # should only be initiliazed once
      @promise_queue.async(@group) do
        begin
          @value = @computation.call
        rescue ::Exception => e
          @exception = e
        end
      end
    end


    # Wait fo the computation to finish. If it has already finished, then
    # just return the value in question.
    def __value__
      __force__ unless @running
      @group.wait
      ::Kernel.raise(@exception) if @exception
      @value
    end


    # like method_missing for objc
    # without this 'promise = Dispatch::Promise.new { NSData.dataWithContentsOfFile(file_name) }' will not work
    # NSString.alloc.initWithData(promise, encoding:NSUTF8StringEncoding)
    # since promise will not respond to NSData#bytes and return a NSInvalidArgumentException
    def method_missing(meth, *args, &block)
      __value__.send(meth, *args, &block)
    end


    def respond_to_missing?(method_name, include_private = false)
      __value__.respond_to?(method_name, include_private) || super
    end


    def forwardingTargetForSelector(sel)
      __value__ if __value__.respond_to?(sel)
    end
  end
end
