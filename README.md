## Synopsis

A simple to do program, complete with due dates, categories, undelete, etc.
Currently a one-person app; still need to add a lot more unit tests, user
account support, and editing of existing entries. Written in Ruby/Sinatra.

## Installation

Simply download into any directory you like, make sure you have Ruby and the
Ruby gem 'bundler' installed, then run `bundle install`. Then run `ruby todo.rb`
and go to http://localhost:4567

## Tests

Make sure the Ruby gem `rake` is installed, then run `rake test` in the main
directory (the place where `todo.rb` is).

I need help writing tests of the `post` logic. I just have to write a bunch of
unit tests (and refactor generally).

## Contributors

Just Larry Sanger (yo.larrysanger@gmail.com) at this point.
