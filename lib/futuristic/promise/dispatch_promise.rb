module Dispatch
  module_function
  def promise(queue=Dispatch::Queue.concurrent, &block)
    promise = Promise.new
    queue.async do
      result = block.call
      Dispatch::Queue.main.async do
        if result.nil? || result.is_a?(NSError) || result.is_a?(Exception)
          promise.reject(result)
        else
          promise.fulfill(result)
        end
      end
    end
    promise
  end
end