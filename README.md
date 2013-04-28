#Futures and Promises
This is a rubymotion implementation of the Futures and Promise pattern, on top of Grand Central [Dispatch](https://github.com/MacRuby/MacRuby/wiki/Dispatch-Module).

##What are Futures and Promises?

> In computer science, future, promise, and delay refer to constructs used for 
> synchronizing in some concurrent programming languages. They describe an object 
> that acts as a proxy for a result that is initially unknown, usually because the 
> computation of its value is yet incomplete<[source Wikipedia](http://en.wikipedia.org/wiki/Futures_and_promises)>.


##Futures and Promises
are objects holding a value which may become available at some point. This value is usually the result of some other computation. Since this computation may fail with an exception, the Future may also hold an exception in case the computation throws one.

#Usage:

in your Gem file

```ruby
gem 'futuristic'

```
###how to use Promises
```ruby
def fibonacci(n)
  return n if n < 2
  fib1 = Dispatch::Promise.new { fibonacci(n-1) }
  fib2 = Dispatch::Promise.new { fibonacci(n-2) }
  fib1 + fib2
end

p fibonacci(10) # => 55
```

###how to use Futures

```ruby
# computation is started
future_data = Dispatch::Future.new do
	bundle	= NSBundle.mainBundle
	plist_path = bundle.pathForResource("map", ofType: "plist")
	@map_data = load_plist(File.read(plist_path))
end

# you can do something else
@table = create_table_named("Future Maps")

puts "Hello World"

@table.data = future_data.value # if the computation is done, results with be immediatelly returned, if not done yet it will wait.
```

###Futures using callback
```ruby
# computation is started
future_data = Dispatch::Future.new do
	bundle	= NSBundle.mainBundle
	plist_path = bundle.pathForResource("map", ofType: "plist")
	@map_data = load_plist(File.read(plist_path))
end

# you can do something else
@table = create_table_named("Future Maps")

future_data.when_done do |value|
	# when the computation is done, table data will be setted on the Future Queue
	# the call back is not executed on the MainQueue/Dispatch::Queue.main
	@table.data = future_data.value
end
```

###Module Futuristic
```ruby
class Request

  include Dispatch::Futuristic
  
  def long_taking_computation
  	sleep 10
  	42
  end
end

request = Request.new
computation = request.future.long_taking_computation

#you can do something else while the computation is been executed on a background queue
puts "Drink some Kölsch"

# now you need the result, if it's already finished
# you will ge the result, otherwise it will wait untill the computation finish
p computation.value  # =>  42
```

#Todo
- Parallel Enumerable 
- Actor models
- documentation and examples
