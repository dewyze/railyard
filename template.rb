def source_paths
  [__dir__]
end

gem_group :development, :test do
  gem "better_errors"
  gem "pry-byebug"
  gem "rubocop", require: false
  gem "rubocop-performance", require: false
  gem "rubocop-rails", require: false
  gem "rubocop-rspec", require: false
  gem "rspec-rails"
  gem "factory_bot_rails"
end

gem_group :development do
  gem "web-console"
end

gem "bcrypt"
gem "image_processing"

copy_file "~/dev/railyard/rails.gitignore", ".gitignore"
copy_file "~/dev/railyard/rubocop.yml", ".rubocop.yml"

# TODO: Add Devise
gsub_file 'Gemfile', /^(#[^#\n]+|\n*)$/i, ''
gsub_file 'Gemfile', /([^\n]+)\n\n+$/im, '\1'

after_bundle do
  generate "rspec:install", "--force"

  application do
    <<-CODE
    config.generators do |generate|
      generate.test_framework :rspec
      generate.helper false
      generate.javascript_engine false
      generate.stylesheets false
    end

    CODE
  end

  directory "files", "."

  # TODO: Run rubocop
end
