# Future
# actually future acts just like a Promise,
# the only difference is that they are not lazy
module Dispatch
    class Future < Promise
        # Create s new Future
        #
        # Example:
        # >> future = Dispatch::Future.new { long_taking_task; 10 }
        # => future.value # 10
        # Arguments
        # block, last
        # new :: a -> Future b
        def self.new(&block)
            # MacRuby and Rubymotion BasicObject#initialize doesn't like blocks, so we have to do this
            unless block_given?
                ::Kernel.raise(::ArgumentError, "You cannot initalize a Dispatch::Future without a block")
            end
            self.alloc.initialization(block)
        end

        def when_done(&call_back)
            @whe_done = call_back.weak!
            @group.notify(@promise_queue) { @whe_done.call __value__ }
            self
        end

        def initialization(block)
            super(block)
            __force__
            self
        end

        #
        # Future#description
        # => <Future: 0x400d382a0 run> 
        #

        def description
            state = done? ? :dead : :run
            NSString.stringWithString(super.gsub(/>/, " #{state}>"))
        end

        alias_method :to_s, :description
        alias_method :inspect, :description

        def done?
            !!@value
        end

        def value
            __value__
        end
    end
end
