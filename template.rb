# def run(cmd, quiet=false)
#   cmd += " > /dev/null/" if quiet
#   system(cmd)
# end

def source_paths
  [__dir__]
end

# Gemfile
gsub_file "Gemfile", /.*tzinfo-data.*/, ""
gsub_file "Gemfile", /.*byebug.*/, ""

insert_into_file "Gemfile", before: "group :development, :test" do
  <<-GEMS
gem "bcrypt"
gem "image_processing"

gem "devise"
gem "pundit"
gem "turbolinks_render"
  GEMS
end

insert_into_file "Gemfile", after: "group :development, :test do\n" do
  <<-GEMS
  gem "better_errors"
  gem "capybara"
  gem "factory_bot_rails"
  gem "faker"
  gem "pundit-matchers"
  gem "pry-byebug"
  gem "rails-controller-testing"
  gem "rubocop", require: false
  gem "rubocop-performance", require: false
  gem "rubocop-rails", require: false
  gem "rubocop-rspec", require: false
  gem "rspec-rails"
  gem "shoulda-matchers"
  GEMS
end

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
  Bundler.with_unbundled_env do
    system("bundle binstubs rubocop")
  end

  system("bin/rake environment db:drop:all db:create db:migrate")

  # Setup Devise
  generate("devise:install")
  insert_into_file "config/environments/development.rb", before: /.*config\.action_mailer/ do
    <<-CODE
  config.action_mailer.default_url_options = { host: \"localhost\", port: 3000 }\n
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = { :address => "localhost", :port => 1025 } # mailcatcher
    CODE
  end
  insert_into_file "config/environments/production.rb", before: /.*config\.action_mailer/ do
    <<-CODE
  # TODO: Change
  config.action_mailer.default_url_options = { host: \"myhost\", port: 3000 }\n
    CODE
  end

  generate("devise User")
  generate("devise:views")
  generate("devise:controllers users -c=registrations")

  # Setup Pundit
  # TODO: Give choice with CanCanCan
  generate("pundit:install")

  # Customize Devise and Pundit
  insert_into_file "app/controllers/application_controller.rb", after: /class ApplicationController.*\n/ do
    <<-'CODE'
  include Pundit

  before_action :authenticate_user!
  after_action :verify_authorized, except: :index, unless: :devise_controller?
  after_action :verify_policy_scoped, only: :index, unless: :devise_controller?

  rescue_from Pundit::NotAuthorizedError do |e|
    message = e.reason ? I18n.t("pundit.errors.#{e.reason}") : e.message
    flash[:error] = t(message, scope: "pundit", default: :default)
    redirect_to(request.referrer || root_path)
  end
    CODE
  end

  append_to_file "config/locales/en.yml" do
    <<-CODE
  pundit:
    default: "You are not authorized to perform that action."
     CODE
  end

  inject_into_file "app/controllers/users/registrations_controller.rb", before: /^end\Z/ do
    <<-CODE
  def after_update_path_for(_resource)
    edit_user_registration_path # TODO: User show page? Dashboard?
  end
    CODE
  end

  append_to_file "app/javascript/packs/appliation.js" do
    <<-CODE
const images = require.context("../images", true);
const imagePath = (name) => images(name, true);

import Turbolinks from "turbolinks";
Turbolinks.start();
    CODE
  end

  # spec_helper
  gsub_file "spec/spec_helper.rb",
    /config\.example_status_persistence_file_path = \"spec\/examples.txt\"/,
    "config.example_status_persistence_file_path = \"tmp/rspec.txt\""
  uncomment_lines "spec/spec_helper.rb", /config\.example_status_persistence_file_path/
  uncomment_lines "spec/spec_helper.rb", /config.order = :random/

  # rails_helper
  inject_into_file "spec/rails_helper.rb", after: /.*require.*rspec\/rails.*\n/ do
    "require \"pundit/matchers\""
  end
  gsub_file "spec/rails_helper.rb", /^end\Z/ do
    <<-CODE

  config.include Devise::Test::IntegrationHelpers, type: :request
  config.include FactoryBot::Syntax::Methods
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
    CODE
  end

  # Copy files
  copy_file "~/dev/railyard/rails.gitignore", ".gitignore"
  copy_file "~/dev/railyard/rubocop.yml", ".rubocop.yml"

  directory "files", "."
  chmod "bin/redb", 0755

  # Setup
  system("bin/redb")

  say "Please install mailcatcher" unless system("which mailcatcher")

  system("bin/rake")
end
