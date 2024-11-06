# Sluggi

[![Gem Version](https://img.shields.io/gem/v/sluggi.svg)](https://rubygems.org/gems/sluggi)
[![Build Status](https://github.com/neighborland/sluggi/actions/workflows/ruby.yml/badge.svg)](https://github.com/neighborland/sluggi/actions/workflows/ruby.yml)

Sluggi is a simple [friendly_id](https://github.com/norman/friendly_id)-inspired slugging library for ActiveRecord models. It is faster than `friendly_id` (see below for benchmarks).

It provides basic slugs, slug history, and the ability to define multiple slug candidates.

## Versions

The gemspec includes the `activerecord` version dependency, so the correct version of `sluggi` will be installed to match your `activerecord` version.

| sluggi | activerecord |
| --: | --: |
| 0.5 | 4.0-5.0 |
| 1.0 | 5.1-5.2 |
| 2.0 | 6.x |
| 3.0 | 7.x |

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

Override `#slug_candidates` to define cascading candidate values for slugs.
This is useful to avoid uniqueness conflicts. Do not override `#slug_value` -
the default implementation in `Model` will call `#slug_candidates` and
works with or without `History`.

```ruby
class Cat < ActiveRecord::Base
  include Sluggi::Slugged

  # The first unused value in the list is used.
  # Each item may be a value or a lambda.
  # Use a lambda to defer expensive unique value calculations.
  def slug_candidates
    [
      name,
      -> { "#{name}-#{Cat.count}" }
    ]
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
=> 'tuxedo-stan-456'
```

## Performance

Run the benchmark script: `ruby bench.rb`. This script is based on the
benchmark script from `friendly_id`.

Here are some anecdotal results using ruby 2.5.3:

```
                                                  SLUGGI      FRIENDLY_ID
1) find (id) - direct ActiveRecord                0.092318    0.093049
2) find (in-table slug)                           0.102773    0.259542
3) find (in-table slug; using finders module)     0.098183    0.108248
4) find (external slug)                           0.670229    0.832791
5) insert (plain AR / no slug)                    0.345077    0.345105
6) insert (in-table-slug)                         0.666451    0.815505
7) insert (in-table-slug; using finders module)   0.668737    0.744433
8) insert (external slug)                         2.480790    2.849761
```

Notes:

Sluggi is at least 10% faster in every benchmark.

1) Baseline (does not use either gem)
2) 0.44x
3) 0.90x
4) 0.80x
5) Baseline (does not use either gem)
6) 0.82x
7) 0.90x
8) 0.87x


## Alternatives

* [override ActiveRecord#to_param](http://guides.rubyonrails.org/active_support_core_extensions.html#to-param)
* [use ActiveRecord.to_param](https://github.com/rails/rails/pull/12891)
* [friendly_id](https://github.com/norman/friendly_id)
* [slug](https://github.com/bkoski/slug)
* [slugged](https://github.com/Sutto/slugged)
* [others](https://rubygems.org/search?utf8=%E2%9C%93&query=slug)
