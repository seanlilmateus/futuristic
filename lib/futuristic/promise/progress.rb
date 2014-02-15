module Dispatch # Progress
  class Promise
    module Progress
      # Progress
      def on_progress(&block)
        @on_progress ||= []
        @on_progress << block if block_given?
        @on_progress
      end

      def progress(status)
        if pending?
          on_progress.each { |block| block.call(status) }
        end
      end
    end
  end
end