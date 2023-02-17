# ArSearchable

Add scopes to Active Record models.

## Installation

Install the gem and add to the application's Gemfile by executing:

    gem 'ar_searchable', git: 'https://github.com/jpgeek/ar_searchable'

and run 'bundle install`

## Usage

In your model, add:

    include ArSearchable

Then specify the fields and the type of searchable functionality you desire.
Ex, given a model Foo with fields "keywords", "name" and "description", you can add
search methods with:

    searchable_string_like :keywords, :first_name, :description

This creates the following named scopes on Foo
    Foo.by_keywords_like(string)
    Foo.by_first_name_like(string)
    Foo.by_desciption_like(string)

These are all simply AR relations, so you can chain them to your own calls,
extract raw sql from them etc.  Ex:
    User.by_name_like('bob').where(active: true)

    Prefecture.by_name_like('foo').to_sql
    => "SELECT `prefectures`.* FROM `prefectures` WHERE (prefectures.name LIKE '%foo%')"

The each of these is just an ar scope with the table-name qualified field,
"LIKE" and the string entered.

Other searchable methods are:
    searchable_date_range(*args)
    searchable_date_from(*args)
    searchable_date_to(*args)
    searchable_date(*args)
    searchable_numeric(*args)
    searchable_numeric_range(*args)
    searchable_numeric_from(*args)
    searchable_numeric_to(*args)
    searchable_string_like(*args)
    searchable_phone_number(*args)
    searchable_postal_code(*args)

These will create the similarly named methods
    by_date_range(from_date, to_date)
    by_date_from(from_date)
    by_date_to(to_date)
    by_date(date)
    by_numeric(numeric)
    by_numeric_range(from_numeric, to_numeric)
    by_numeric_from(from_numeric)
    by_numeric_to(to_numeric)
    by_string_like(string)
    by_phone_number(phone_number)
    by_postal_code(postal_code)
## Development

After checking out the repo, run `bundle` to install dependencies. Then, run `rspec` to run the tests.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jpgeek/ar_searchable. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/jpgeek/ar_searchable/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the ArSearchable project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/jpgeek/ar_searchable/blob/main/CODE_OF_CONDUCT.md).
