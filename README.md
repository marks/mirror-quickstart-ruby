Google Mirror API's Quick Start for Ruby (using Sinatra)
====

The documentation for this quick start is maintained on developers.google.com.
Please see here for more information:
https://developers.google.com/glass/quickstart/ruby

___________


Mark's Modifications
---
- Structural cleanup:
  - Moved `client_secrets.json` into new `config/` folder
  - Moved `mirror_quick_start.rb` to `app.rb`
  - Moved `oauth_utils.rb`, `mirror_client.rb`, and `credentials_store.rb` to `lib/google` 
- Added `Procfile` to support Heroku/`foreman`
- Added ability to specify scopes in `get_authorization_url` method [commit](https://github.com/marks/mirror-quickstart-ruby/commit/864da18f50a899ee67428c16dff256387ad2a65e)

Mark's To Do
---
- ~~Be able to delete timeline cards created from this quickstart from the device~~
  - just had to add `menuItems: [{ action: 'DELETE' }]` to timeline item
- Record responses to cards in database (right now they are just inserted into the timeline)
