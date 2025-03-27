require 'sequel'
require 'dotenv'
require 'logger'
require 'fileutils'

# Load environment variables
Dotenv.load(File.join(__dir__, '..', '.env'))

# Make sure the db directory exists
FileUtils.mkdir_p(File.join(__dir__))

# Database URL
db_url = ENV['DATABASE_URL'] || 'sqlite://db/development.db'

# Connect to the database
DB = Sequel.connect(db_url)
DB.loggers << Logger.new($stdout)

puts "Connected to database #{db_url}"

# Run migrations
Sequel.extension :migration
puts "Running migrations..."
Sequel::Migrator.run(DB, File.join(__dir__, 'migrations'))
puts "Migrations completed successfully!"

puts "Database setup completed!" 