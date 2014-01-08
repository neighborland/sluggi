# Sluggi

[![Gem Version](https://badge.fury.io/rb/sluggi.png)](http://badge.fury.io/rb/sluggi)

Sluggi is a simple [friendly_id](https://github.com/norman/friendly_id)-inspired slugging library for ActiveRecord models.

It provides basic slugs, slug history, and the ability to define multiple slug candidates.

Sluggi works with Rails 4.0+.

## Install

Add this line to your Gemfile:

```ruby
gem 'sluggi'
```

Add a string column named `slug` to any models you want to slug. You can generate a migration like so:

```sh
rails generate migration AddSlugToCats slug:string
```
```ruby
# edit the migration to add a unique index:
add_index :cats, :slug, unique: true
```
```sh
rake db:migrate
```

To track slug history for any model, you must generate a migration to add the `slugs` table:

```sh
rails generate sluggi
rake db:migrate
```

## Usage

Sluggi is Magic Free(tm). Each slugged model must:

* Have a column named `slug` (see above).
* Include the `Sluggi::Slugged` module
* Override the `slug_value` method or the `slug_candidates` method.

### Simple Slugged Model

```ruby
class Cat < ActiveRecord::Base
  include Sluggi::Slugged

  def slug_value
    name
  end

  def slug_value_changed?
    name_changed?
  end
end
```

```ruby
cat = Cat.create(name: 'Tuxedo Stan')
cat.slug
=> 'tuxedo-stan'

cat.to_param
=> 'tuxedo-stan'

cat_path
=> 'cats/tuxedo-stan'

Cat.find_by_slug('tuxedo-stan')
=> cat
```

### Model with Slugged History

```ruby
class Cat < ActiveRecord::Base
  include Sluggi::Slugged
  include Sluggi::History

  def slug_value
    name
  end

  def slug_value_changed?
    name_changed?
  end
end
```

```ruby
cat = Cat.create(name: 'Tuxedo Stan')
cat.slug
=> 'tuxedo-stan'

cat.name = 'Tuxedo Bob'
cat.save
cat.slug
=> 'tuxedo-bob'

# use .find_slug! to search slug history:

Cat.find_slug!('tuxedo-bob')
=> cat
Cat.find_slug!('tuxedo-stan')
=> cat

# plain finders will not search history:

Cat.find_by_slug('tuxedo-bob')
=> cat

Cat.find_by_slug('tuxedo-stan')
=> RecordNotFound

```

### Model with Slug Candidates

```ruby
class Cat < ActiveRecord::Base
  include Sluggi::Slugged

  def name_and_id
    "#{name}-#{id}"
  end

  # the first unused value in the list is used
  def slug_candidates
    [name, name_and_id]
  end

  def slug_value_changed?
    name_changed?
  end
end
```

```ruby
cat = Cat.create(name: 'Tuxedo Stan')
cat.slug
=> 'tuxedo-stan'

cat_2 = Cat.create(name: 'Tuxedo Stan')
cat_2.slug
=> 'tuxedo-stan-2'
cat_2.id
=> 2

```

## Alternatives

[override ActiveRecord#to_param](http://guides.rubyonrails.org/active_support_core_extensions.html#to-param)
[use ActiveRecord.to_param](https://github.com/rails/rails/pull/12891)
[friendly_id](https://github.com/norman/friendly_id)
[slug](https://github.com/bkoski/slug)
[slugged](https://github.com/Sutto/slugged)
[others](https://rubygems.org/search?utf8=%E2%9C%93&query=slug)
