describe Dispatch::Promise do
  before do
    @method = Dispatch::Promise.method(:new)#Kernel.method(:promise)
  end

  it "should inherit from BasicObject if available, and not otherwise" do
    Dispatch::Promise.ancestors.should.include BasicObject
  end

  behaves_like "A Promise"

  it "should delay execution" do
    value = 5
    x = @method.call { value = 10 ; value }
    value.should == 5
    y = x + 5
    y.should == 15
    value.should == 10
  end

  it "should delay execution of invalid code" do
    lambda { 1 / 0 }.should.raise(ZeroDivisionError).message.should.match(/divided by 0/)
    lambda { x = [ 1, @method.call { x / 0 }]}.should.not.raise(ZeroDivisionError)
  end
end
