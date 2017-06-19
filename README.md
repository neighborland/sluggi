# Sluggi

[![Gem Version](http://img.shields.io/gem/v/sluggi.svg)](http://rubygems.org/gems/sluggi)
[![Build Status](http://img.shields.io/travis/neighborland/sluggi.svg)](https://travis-ci.org/neighborland/sluggi)

Sluggi is a simple [friendly_id](https://github.com/norman/friendly_id)-inspired slugging library for ActiveRecord models.

It provides basic slugs, slug history, and the ability to define multiple slug candidates.

Sluggi 1.x works with Rails 5.1+.
Sluggi 0.5.x works with Rails 4.0-5.0.x. Make sure to view the 0.5-stable branch's Readme for
those versions.

## Install

Add this line to your Gemfile:

```ruby
gem 'sluggi'
```

Add a string column named `slug` to any models you want to slug. You can generate a migration like so:

```sh
rails generate migration AddSlugToCats slug:string:uniq:index
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

Specify the slug value by defining `#slug_value` and `#slug_value_changed?`.

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

To save slug history, include `Sluggi::History`. You get a `slugs` association. You can search for any
slug in the history using `.find_slug!`.

You must also implement `#saved_change_to_slug_value?`.

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

  def saved_change_to_slug_value?
    saved_change_to_name?
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

Override `#slug_candidates` to define cascading candidate values for slugs. This is useful to avoid
uniqueness conflicts.

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

* [override ActiveRecord#to_param](http://guides.rubyonrails.org/active_support_core_extensions.html#to-param)
* [use ActiveRecord.to_param](https://github.com/rails/rails/pull/12891)
* [friendly_id](https://github.com/norman/friendly_id)
* [slug](https://github.com/bkoski/slug)
* [slugged](https://github.com/Sutto/slugged)
* [others](https://rubygems.org/search?utf8=%E2%9C%93&query=slug)
