# Database stuff
DataMapper::setup(:default, ENV["DATABASE_URL"] || "sqlite3://#{Dir.pwd}/db/dev.db")

class Credentials
  include DataMapper::Resource
  property :user_id, String, :key => true
  property :access_token, String
  property :refresh_token, String
end

DataMapper.finalize
DataMapper.auto_upgrade!
