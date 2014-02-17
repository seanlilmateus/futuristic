motion_require './promise/promise'

module Dispatch # Atomic
  class Atomic < BasicObject

    def self.new(object=nil)
      instance = alloc.initWithObject(object)
    end

    def initWithObject(object)
      init
      @object = object
      @queue = ::Dispatch::Queue.new "#{@object.object_id}-de.mateus.synchronized.proxy"
      self
    end

    def update
      @queue.sync do
        old_value = @object
        new_value = yield(old_value)
        @object = new_value unless new_value == @object
        return new_value
      end
    end

    # you can't get the value <@object> while @object is being updated
    def value
      @queue.sync { return @object }
    end

    def method_missing(m, *args, &blk)
      @queue.sync do
        options = args.find { |arg| arg.is_a?(::Hash) }

        if options
          selector  = options.keys.unshift(m).map { |txt| txt.to_s.appendString(':') }.join   
          arguments = options.values.unshift(args.first)
        end

        target = @object
        ret_value = if selector && target.respond_to?(selector)
          target.__send__(selector, *arguments, &blk)
        elsif target.respond_to?(m)
          target.__send__(m, *args, &blk)
        end
        return ret_value
      end
    end

    def inspect
      description.gsub(/Atomic/, "#{self.class} [#{@object.class}]")
    end

  end
end