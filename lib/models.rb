# Database stuff
DataMapper::setup(:default, ENV["DATABASE_URL"] || "sqlite3://#{Dir.pwd}/db/dev.db")

class Credentials
  include DataMapper::Resource
  property :user_id, String, :key => true
  property :access_token, String, :length => 255
  property :refresh_token, String, :length => 255
end

DataMapper.finalize
DataMapper.auto_upgrade!
