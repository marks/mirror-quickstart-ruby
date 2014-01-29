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


Mark's To Do
---
- Be able to delete timeline cards created from this quickstart from the device8