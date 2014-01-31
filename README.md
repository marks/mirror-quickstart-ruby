A fork of: Google Mirror API's Quick Start for Ruby (using Sinatra)
====

___________


Mark's Modifications
---
... read the commits, silly!

Mark's To Do
---
- ~~Be able to delete timeline cards created from this quickstart from the device~~
  - just had to add `menuItems: [{ action: 'DELETE' }]` to timeline item
- ~~Add `config/app.yml` to govern app configuration stuff~~
- ~~Move from straight up SQLite to DataMapper~~
- Refactor Google::APIClient auth out of MirrorClient; for now, use @mirror.client to accessible Google::APIClient
- Record responses to cards in database (right now they are just inserted into the timeline)

FAQ
---
- What is debug mode? (it can be set in `config/app.yml`)?
  -  When debug mode is enabled, the app shows extra output in the browser/glassware and uses [Google's Subscription Proxy](https://developers.google.com/glass/tools-downloads/subscription-proxy)

- How do I use the credentials to make a non-Mirror API call?
  - Example of how to get user profile information (allowed by the `userinfo.profile` OAuth scope)
  
    ````
      # user_id = Credentials.first.user_id
      plus = @mirror.client.discovered_api('plus')
      @mirror.client.authorization = get_stored_credentials(user_id)
      result = @mirror.client.execute(
        :api_method => plus.people.get,
        :parameters => {'collection' => 'public', 'userId' => 'me'}
      )

- How do I run this locally?
  1. `bundle install`
  2. Configure by settings* in `config/app.erb.yml` as needed and/or setting respective environment variables. I suggest using [foreman local variable set up as suggested by Heroku](https://devcenter.heroku.com/articles/config-vars#local-setup)
  3. `bundle exec ruby app.rb` or `foreman start`

- How do I run this on Herkou?
  1. `heroku create`
  2. Depending on where you want to store configuration variables*, set variables in `config/app.erb.yml` and/or [set Heroku environment variables](https://devcenter.heroku.com/articles/config-vars#setting-up-config-vars-for-a-deployed-application)
  3. `git push heroku master`

* = see original Google documentation, below, for how to create an API project and get the right IDs, secrets, etc. from the [Google API console](https://cloud.google.com/console/project)
CivOmega Caveats
---
- Only shows/displays first two columns

___________

The original documentation for this quick start is maintained on developers.google.com.
Please see here for more information:
https://developers.google.com/glass/quickstart/ruby

