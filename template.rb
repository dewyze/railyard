gem "pg", "~> 0.18.4"

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

# gem "bcrypt" for secure passwords
# gem "image_processing" for active storage variants

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

  # Dir["files/**/*.rb"],each do |fname|
  #   local_name = fname.gsub(/^files\//, "")
  #   copy_file fname, local_name
  # end
  #
  # route "root to: \"pages#home\""
  #
  # if yes? "Add a basic User model? (y/n)"
  #   generate(:scaffold, "User", "username:string", "first_name:string", "last_name:string")
  # end
end
