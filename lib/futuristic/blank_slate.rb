# This code is meant to fix the BasicObject
# to act more like the Default MRI implementation
class BlankSlate < BasicObject
  def self.new(*arguments, &blk)
    instance = alloc
    instance.initialize(*arguments, &blk)
    instance
  end
end