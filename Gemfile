# frozen_string_literal: true

source "https://rubygems.org"

gemspec

gem "rails", github: "rails/rails"
gem "arel", github: "rails/arel"
gem "rack", github: "rack/rack"

group :development do
  platform :ruby do
    gem "byebug"
  end
  gem "puma"
end

group :test do
  gem "rake"
  gem "mocha", require: false
  gem "simplecov", require: false
end
