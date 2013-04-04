class Atomic
  def initialize(value=nil)
    @queue = Dispatch::Queue.new("org.macruby.atomic.#{__id__}")
    @value = value
  end


  def get
    @queue.sync { return @value }
  end
  alias value get
  
  
  def set(new_value)
    @queue.sync { @value = new_value }
  end
  alias value= set


  def get_and_set(new_value)
    @queue.sync do
      old_value = @value
      @value = new_value
      return old_value
    end
  end
  alias swap get_and_set


  def compare_and_set(old_value, new_value)
    @queue.sync do
      return false unless @value.equal? old_value
      @value = new_value
      return true
    end
  end
  alias compare_and_swap compare_and_set
end