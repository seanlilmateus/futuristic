describe Dispatch::Atomic do

  before do
    @atomic = Dispatch::Atomic.new(0)
  end

  it 'atomic value should be 0' do
    @atomic.value.should == 0
  end

  it 'atomic value should be 0' do
    @atomic.value.should == 0
  end

  it 'should support concurrent operation' do
    Dispatch::Queue.concurrent.apply(1000) do |idx|
      @atomic.update { |v| v + idx }
    end
    @atomic.value.should == 500500
  end

end
