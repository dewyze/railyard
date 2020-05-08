namespace :db do
  desc "Rebuild db from scratch"
  task rebuild: ["environment", "db:drop", "db:create", "db:migrate", "db:seed", "db:test:prepare"] do
    puts "Rebuilding completed."
  end
end
