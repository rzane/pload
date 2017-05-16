# Pload

Pload will prevent Active Record from loading associations that weren't eager loaded.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'pload'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install pload

Throw this in an initializer:

```ruby
Pload.raise_errors!
```

## Usage

Imagine you have 100 posts, and they each have an author. The following would create N+1 query:

```ruby
Post.all.each { |post| puts post.author }
```

This would run 101 queries. On larger applications, it is incredibly easy for these to accidentally slip through the cracks. Wouldn't it be nice if this would throw an error?

```ruby
Post.pload.all.each { |post| puts post.author }
```

Boom! You're going to get an error now. It can be easily solved by using includes:

```ruby
Post.pload.includes(:author).each { |post| puts post.author }

# or, you can use the shorthand
Post.pload(:author).each { |post| puts post.author }
```

Don't want to have to specify `.pload`? Just use `pload` in combination with `default_scope`.

```ruby
class Post < ActiveRecord::Base
  default_scope { pload }
end
```

And if you want to bypass the error, you can just pass `pload: false` to the association:

```ruby
Post.pload.all.each { |post| puts post.author(pload: false) }
```

## Production

Don't want to raise errors in production? Change your initializer to look like this:

```ruby
Pload.raise_errors! unless Rails.env.production?
```

The `pload` method will still be available, but it won't raise errors for N+1 queries.

## Bullet compatibility

You can use Pload and Bullet at the same time, but because of the way Bullet monkey-patches Active Record, you'll need to take some precaution.

Make absolutely sure that `Pload.raise_errors!` comes after `Bullet.enable = true`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/rzane/pload.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
