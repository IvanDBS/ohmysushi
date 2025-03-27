require 'sequel'
require 'dotenv/load'
require 'logger'

module DBSetup
  def self.init
    # Connect to database
    db_url = ENV['DATABASE_URL'] || 'sqlite://db/development.db'
    db = Sequel.connect(db_url)
    db.loggers << Logger.new($stdout) if ENV['RACK_ENV'] == 'development'
    
    # Run migrations first
    Sequel.extension :migration
    Sequel::Migrator.run(db, 'db/migrations')
    
    # Then load models
    Dir['./lib/models/*.rb'].each { |file| require file }
    
    # Return DB connection
    db
  end
end 