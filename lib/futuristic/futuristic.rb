# Futuristic
module Futuristic
    def future
        proxy = Class.new(BasicObject) do
            def initialize(obj)
                @object = obj
            end

            def method_missing(meth, *args, &blk)
                Dispatch::Future.new { @object.send(meth, *args, &blk) }
            end

            def respond_to_missing?(meth, include_private = false)
                @object.respond_to?(meth) || super
            end
        end
        proxy.new(self)
    end
end
