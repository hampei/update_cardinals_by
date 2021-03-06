begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

require 'rdoc/task'

Bundler::GemHelper.install_tasks

task default: :spec

task :setup do
  if File.exist?('.env')
    puts 'This will overwrite your existing .env file'
  end
  print 'Enter your database name: [update_cardinals_by] '
  db_name = STDIN.gets.chomp
  print 'Enter your database user: [] '
  db_user = STDIN.gets.chomp
  print 'Enter your database password: [] '
  db_password = STDIN.gets.chomp
  print 'Enter your database server: [localhost] '
  db_server = STDIN.gets.chomp

  db_name = 'update_cardinals_by' if db_name.empty?
  db_password = ":#{db_password}" unless db_password.empty?
  db_server = 'localhost' if db_server.empty?

  db_server = "@#{db_server}" unless db_user.empty?

  env_path = File.expand_path('./.env')
  File.open(env_path, 'w') do |file|
    file.puts "DATABASE_NAME=#{db_name}"
    file.puts "DATABASE_URL=\"postgres://#{db_user}#{db_password}#{db_server}/#{db_name}\""
  end

  puts '.env file saved'
end

namespace :db do
  task :load_db_settings do
    require 'active_record'
    unless ENV['DATABASE_URL']
      require 'dotenv'
      Dotenv.load
    end
  end

  task :drop => :load_db_settings do
    %x{ dropdb #{ENV['DATABASE_NAME']} --if-exists }
    puts 'Database dropped'
  end

  task :create => :load_db_settings do
    %x{ createdb #{ENV['DATABASE_NAME']} }
    puts 'Database created'
  end

  task :setup => [:drop, :create] do
    ActiveRecord::Base.establish_connection

    ActiveRecord::Base.connection.enable_extension 'hstore'

    ActiveRecord::Base.connection.create_table :accounts, force: true do |t|
      t.integer  "credits"
      t.decimal  "money"
    end

    puts 'Database tables created'
  end
end