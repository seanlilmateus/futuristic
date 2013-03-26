describe Dispatch::Future do

  before { @method = Kernel.method(:future) }
  
  it "should inherit from BasicObject if available, and not otherwise" do
    Dispatch::Future.ancestors.should.include BasicObject
  end
  
  # behaves_like "A Promise"
  
  def range_of(range)
     lambda { |obj| range.include?(obj) }
  end
    
  it "should work in the background" do
    start = Time.now
    x = future { sleep 3; 5 }
    middle = Time.now
    y = x.value + 5
    y.should == 10
    finish = Time.now
    (middle - start).should.be range_of(0.0..1.0)
    (finish - start).should.be range_of(3.0..3.9)    
  end
end