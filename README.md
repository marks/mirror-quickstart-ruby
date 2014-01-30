Google Mirror API's Quick Start for Ruby (using Sinatra)
====

The documentation for this quick start is maintained on developers.google.com.
Please see here for more information:
https://developers.google.com/glass/quickstart/ruby

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
  -  When debug mode is enabled, the app shows extra output in the browser and uses Google's Subscription Proxy https://developers.google.com/glass/tools-downloads/subscription-proxy

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

- How do I push to Heroku if git it set to ignore the `client_secrets.json` file?
  - Currently, to push to Heroku, I have a seperate `PRODUCTION` branch (that never gets published to GitHub) that does not ignore the `client_secrets.json` file. When I am ready to push to Heroku, I merge the master branch into the `PRODUCTION` branch and then issue the following command to push that branch to Heroku: `git push heroku PRODUCTION:master` so that the local `PRODUCTION` branch is published to Heroku's `master` branch.
  - This is most definitely a bit convoluted and should be revisited soon.

CivOmega Caveats
---
- Only shows/displays first two columns
