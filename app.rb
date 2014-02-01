require 'bundler'
Bundler.require
require 'pp'

# load configuration file
require "sinatra/config_file"
config_file './config/app.erb.yml'

require './lib/models'
require './lib/civomega'
require './lib/google/mirror_client'

include ActiveSupport::Inflector

set :haml, { format: :html5 }
enable :sessions
enable :logging, :dump_errors, :raise_errors

configure :development do 
  Log = Logger.new("log/development.log")
  Log.level  = Logger::INFO 
end

helpers do
  def base_url
    "#{request.env['rack.url_scheme']}://#{request.env['HTTP_HOST']}"
  end
end

before do
  # create Google API client
  @client = Google::APIClient.new
  @client.authorization = Google::APIClient::ClientSecrets.new({
    "web"=> {
      "auth_uri"=>"https://accounts.google.com/o/oauth2/auth",
      "token_uri"=>"https://accounts.google.com/o/oauth2/token",
      "auth_provider_x509_cert_url"=>"https://www.googleapis.com/oauth2/v1/certs",
      "client_secret" => settings.google_oauth["client_secret"],
      "client_email" => settings.google_oauth["client_email"],
      "redirect_uris" => settings.google_oauth["redirect_uris"],
      "client_x509_cert_url" => settings.google_oauth["client_x509_cert_url"],
      "client_id"=> settings.google_oauth["client_id"], 
      "javascript_origins"=> settings.google_oauth["javascript_origins"]
    }
  }).to_authorization
  @client.authorization.scope = [
    'https://www.googleapis.com/auth/glass.timeline',
    'https://www.googleapis.com/auth/glass.location',
    'https://www.googleapis.com/auth/userinfo.profile'
  ]

  @mirror = MirrorClient.new(@client.authorization)#@client.discovered_api( "mirror", "v1" )
  @oauth2 = @client.discovered_api( "oauth2", "v2" )
  @plus = @client.discovered_api( "plus", "v1" )

  @client.authorization.code = params[:code] if params[:code]
  
  #if we get a push from google, do a different lookup based on the userToken
  if request.path_info == settings.google_mirror["subscription_route"]
    @data = JSON.parse(request.body.read)
    puts "*** " + @data.inspect
    token_pair = GoogleUser.get(@data['userToken'])
    @client.authorization.update_token!(token_pair.to_hash)
  else
    if GoogleUser.get(session[:token_id]) #if the user is logged in
      token_pair = GoogleUser.get(session[:token_id])
      @client.authorization.update_token!(token_pair.to_hash)
    end
  end

  # if there is a refresh token and the pair has expired, fetch a new access token
  if @client.authorization.refresh_token && @client.authorization.expired?
    @client.authorization.fetch_access_token!
  end

  #redirect the user to OAuth if we're logged out
  unless @client.authorization.access_token || request.path_info =~ /^\/oauth2/
    redirect to("/oauth2authorize")
  end

end

##
# Handles the index route.
get '/' do
  @message = session.delete(:message)

  @google_plus_info = @mirror.client.execute(
    :api_method => @plus.people.get,
    :parameters => {'collection' => 'public', 'userId' => 'me'}
  )

  @timeline = @mirror.list_timeline(3)

  begin
    @contact = @mirror.get_contact(parameterize(settings.google_mirror["contact_name"]))
  rescue Google::APIClient::ClientError => e
    @contact = nil
  end

  @timeline_subscription_exists = false
  @location_subscription_exists = false
  @mirror.list_subscriptions.items.each do |subscription|
    case subscription.id
    when 'timeline'
      @timeline_subscription_exists = true
    when 'locations'
      @location_subscription_exists = true
    end
  end

  haml :index
end

get "/oauth2authorize" do
  redirect @client.authorization.authorization_uri.to_s, 303
end

get "/oauth2callback" do
  @client.authorization.fetch_access_token!
  @google_plus_info = JSON.parse(@mirror.client.execute(
    :api_method => @plus.people.get,
    :parameters => {'collection' => 'public', 'userId' => 'me'}
  ).response.body)
  token_pair = GoogleUser.get(session[:token_id])
  token_pair = if token_pair
    GoogleUser.get(session[:token_id])
  else
    GoogleUser.create(:token_id => @google_plus_info["id"].to_s, :name => @google_plus_info["displayName"])
  end
  token_pair.update_token!(@client.authorization)
  token_pair.save
  session[:token_id] = token_pair.token_id
  redirect to("/")
end

##
# Called when one of the buttons is clicked that inserts an item into
# the timeline.
post '/insert-item' do
  @mirror.insert_timeline_item(
    {
      text: params[:message],
      menuItems: [
        { action: 'DELETE' },
      ]

    },
    "#{settings.public_folder}/#{params[:imageUrl]}",
    params[:contentType])

  session[:message] = 'Inserted a timeline item.'
  redirect to '/'
end

##
# Called when the button is clicked that inserts a new timeline item
# that you can reply to.
post '/insert-item-with-action' do
  @mirror.insert_timeline_item({
    text: 'What did you have for lunch?',
    speakableText: 'What did you eat? Bacon?',
    notification: { level: 'DEFAULT' },
    menuItems: [
      { action: 'REPLY' },
      { action: 'READ_ALOUD' },
      { action: 'SHARE' },
      { action: 'CUSTOM',
        id: 'safe-for-later',
        values: [{
          displayName: 'Drill Into',
          iconUrl: "#{base_url}/images/drill.png"
        }] },
      { action: 'DELETE' },
    ]
  })

  session[:message] = 'Inserted a timeline item that you can reply to.'
  redirect to '/'
end

##
# Called when the button is clicked that inserts a Haml-rendered HTML
# item into the user's timeline.
post '/insert-pretty-item' do
  locals = {
    blue_line: params[:blue_line],
    green_line: params[:green_line],
    yellow_line: params[:yellow_line],
    red_line: params[:red_line]
  }

  # Make sure to specify layout: false or you'll end up rendering a
  # complete HTML document instead of just the partial.
  html = haml(:pretty, layout: false, locals: locals)
  @mirror.insert_timeline_item({ html: html })

  session[:message] = 'Inserted a pretty timeline item.'
  redirect to '/'
end

##
# Called when the button is clicked that inserts a timeline card into
# all users' timelines.
# post '/insert-all-users' do
#   user_ids = list_stored_user_ids
#   if user_ids.length > 10
#     session[:message] =
#       "Found #{user_ids.length} users. Aborting to save your quota."
#   else
#     user_ids.each do |user_id|
#       user_client = make_client(user_id)

#       user_client.insert_timeline_item({
#         text: "Did you know cats have 167 bones in their tails? Mee-wow!"
#       })
#     end

#     session[:message] = "Sent a cat fact to #{user_ids.length} users."
#   end

#   redirect to '/'
# end

# ##
# # Called when the Delete button next to a timeline item is clicked.
# post '/delete-item' do
#   @mirror.delete_timeline_item(params[:id])
  
#   session[:message] = 'Deleted the timeline item.'
#   redirect to '/'
# end

##
# Called when the button is clicked that inserts a new contact.
post '/insert-contact' do
  @mirror.insert_contact({
    id: parameterize(settings.google_mirror["contact_name"]),
    displayName: settings.google_mirror["contact_name"],
    imageUrls: ["http://www.itespresso.fr/wp-content/uploads/2011/10/opendata.jpg"],
    acceptCommands: [{:type => "TAKE_A_NOTE"}],
    speakableName: settings.google_mirror["contact_name"]
  })
  session[:message] = "Inserted the '#{settings.google_mirror["contact_name"]}' contact."
  redirect to '/'
end

##
# Called when the button is clicked that deletes the contact.
post '/delete-contact' do
  @mirror.delete_contact(parameterize(settings.google_mirror["contact_name"]))
  session[:message] = "Deleted the '#{settings.google_mirror["contact_name"]}' contact."
  redirect to '/'
end

##
# Called to insert a new subscription.
post '/insert-subscription' do
  callback = "#{base_url}#{settings.google_mirror["subscription_route"]}"
  callback = "https://mirrornotifications.appspot.com/forward?url=" + callback if settings.debug_mode
  
  begin
    @mirror.insert_subscription(
      session[:user_id], params[:subscriptionId], callback)

    session[:message] =
      "Subscribed to #{params[:subscriptionId]} notifications."
  rescue
    session[:message] =
      "Could not subscribe because the application is not running as HTTPS."
  end

  redirect to '/'
end

##
# Called to delete a subscription.
post '/delete-subscription' do
  @mirror.delete_subscription(params[:subscriptionId])
  session[:message] = "Unsubscribed from #{params[:subscriptionId]} notifications."
  redirect to '/'
end

##
# Called by the Mirror API to notify us of events that we are subscribed to.
post settings.google_mirror["subscription_route"] do
  # The parameters for a subscription callback come as a JSON payload in
  # the body of the request, so we just overwrite the empty params hash
  # with those values instead.
  params = JSON.parse(request.body.read, symbolize_names: true)

  # The callback needs to create its own client with the user token from
  # the request.
  @client = make_client(params[:userToken])

  case params[:collection]
  when 'timeline'
    params[:userActions].each do |user_action|
      timeline_item_id = params[:itemId]
      timeline_item = @mirror.get_timeline_item(timeline_item_id)

      puts "*** userAction payload => #{params.inspect}"
      puts "*** user acted on => #{timeline_item.inspect}"

      if user_action[:type] == 'SHARE'
        caption = timeline_item.text || ''

        # Alternatively, we could have updated the caption of the
        # timeline_item object itself and used the update method (especially
        # since we needed to get the full TimelineItem in order to retrieve
        # the original caption), but I wanted to illustrate the patch method
        # here.
        @mirror.patch_timeline_item(timeline_item_id,
          { text: "Ruby Quick Start got your photo! #{caption}" })
      elsif timeline_item.recipients.map(&:id).include?(paramaterize(settings.google_mirror["contact_name"]))
        question = timeline_item.text
        @mirror.patch_timeline_item(timeline_item_id, answer_civomega_question(question))
      else
        @mirror.insert_timeline_item({text: "Ruby Quick Start got a timeline item it doesnt know what to do with...\n#{timeline_item.to_hash}" })
      end
    end
  when 'locations'
    location_id = params[:itemId]
    location = @mirror.get_location(location_id)

    # Insert a new timeline card with the user's location.
    if settings.debug_mode
      @mirror.insert_timeline_item({
        text: "You are at " +
          "#{location.latitude} by #{location.longitude}." })
    end
  else
    puts "I don't know how to process this notification: " +
      "#{params[:collection]}"
  end
  return ""
end

##
# A proxy that lets us access the data for attachments (because it requires
# authorization; we cannot just load the URL directly).
get '/attachment-proxy' do
  attachment = @mirror.get_timeline_attachment(
    params[:timeline_item_id], params[:attachment_id])

  content_type attachment.content_type
  @mirror.download(attachment.content_url)
end

get '/civomega/ask' do
  content_type :json
  if params[:question]
    response = answer_civomega_question(params[:question])
  else
    response = "Please specify a question and try again."
  end
  return response.to_json
end

get '/logout' do
  session.clear
  redirect to("/")
end
