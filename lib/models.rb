# Database stuff
DataMapper::setup(:default, ENV["DATABASE_URL"] || "sqlite3://#{Dir.pwd}/db/dev.db")

class GoogleUser
  include DataMapper::Resource

  property :id, Serial
  property :refresh_token, String, :length => 255
  property :access_token, String, :length => 255
  property :expires_in, Integer
  property :issued_at, Integer
  property :phone_number, String, :length => 20

  def update_token!(object)
    self.refresh_token = object.refresh_token
    self.access_token = object.access_token
    self.expires_in = object.expires_in
    self.issued_at = object.issued_at
  end

  def to_hash
    return {
      :refresh_token => refresh_token,
      :access_token => access_token,
      :expires_in => expires_in,
      :issued_at => Time.at(issued_at)
    }
  end
end

DataMapper.finalize
DataMapper.auto_upgrade!
