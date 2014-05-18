#Futures and Promises
This is a rubymotion implementation of the Futures and Promise pattern, on top of Grand Central [Dispatch](https://github.com/MacRuby/MacRuby/wiki/Dispatch-Module).

##What are Futures and Promises?

> In computer science, future, promise, and delay refer to constructs used for 
> synchronizing in some concurrent programming languages. They describe an object 
> that acts as a proxy for a result that is initially unknown, usually because the 
> computation of its value is yet incomplete<[source Wikipedia](http://en.wikipedia.org/wiki/Futures_and_promises)>.


##Futures and Promises
are objects holding a value which may become available at some point. This value is usually the result of some other computation. Since this computation may fail with an exception, the Future may also hold an exception in case the computation throws one.

# Usage
# Promises
On this version, we have rewritten the Promises from scratch,
we throw the whole code away! and start by reusing the code from [lgierth](https://github.com/lgierth),
which means Futuristic now shares the Promises/A+ implementation of [promise.rb](https://github.com/lgierth/promise.rb) an full Promises/A(+) implementation for Ruby.
Nevertheless with had to do some changes, but it both Projects should be compatible.

```ruby

@client = AFMotion::... # create your client

def http_get(url)
  promise = Dispatch::Promise.new

  AFMotion::HTTP.get("http://google.com") do |result|
    if result.success?
      result.fulfill(result.body)
    elsif result.failure?
      result.reject(result.error.localizedDescription)
    end
  end
  promise
end

# 1. options
response = http_get(url).async

# 2. options
success = Proc.new { |value| success value }
failure = Proc.new { |reason| failure reason }
http_get(url).then(success, failure)

# 3. options
http_get(url).then(&method(:success), &method(:failure))
```

For more Information you can visit the [promise.rb's pages](https://github.com/lgierth/promise.rb)


### particular Features
you can call Promise#sync to wait until the Promise is fulfilled or failed

##Futures
```ruby
# computation is started
future = Dispatch::Future.new do
  bundle  = NSBundle.mainBundle
  plist_path = bundle.pathForResource("map", ofType: "plist")
  load_plist(File.read(plist_path))
end

# in the meanwhile you can do something else...
@table = create_table_named("Future Maps")

@table.data = future.value
```

additional to this you can, wait for multiple promises to "be done"

```ruby

f1 = Dispatch::Future.new { get_page('api/pages') }
f2 = Dispatch::Future.new { get_page('api/pagecategories') }
Dispatch::Future.reduce do	|v1, v2|
  render(v1, v2)
end
```
---
# Atomic
This Class provides an Atomic Object that guarantees atomic updates to its contained value.
It provides an accessor for the contained `value` and an update method:

### Usage

*****

```ruby
atomic_number = Dispatch::Atomic.new(0)
atomic_number.value # => 0

atomic_number.update { |v| v + 1 }
atomic_number.value # => 1

Dispatch::Queue.concurrent.apply(1000) do |idx|
  atomic_number.update { |v| v + idx }
end
atomic_number.value # => result 
```
