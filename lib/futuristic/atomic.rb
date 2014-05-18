motion_require './blank_slate'

module Dispatch # Atomic
  class Atomic < BlankSlate
    def initialize(object)
      @object = object
      @queue = Queue.new("de.mateus.futuristic.atomic.#{@object.object_id}")
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
          selector  = options.keys.unshift(m).map { |txt| txt.to_s + ':' }.join   
          arguments = options.values.unshift(args.first)
        end

        target = @object
        ret_value = if selector && target.respond_to?(selector)          
          target.public_send(selector, *arguments, &blk)
        elsif target.respond_to?(m)
          target.public_send(m, *args, &blk)
        else
          super
        end
        return ret_value
      end
    end

    def inspect
      description.gsub(/Atomic/, "#{self.class} [#@object]")
    end
  end
end