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
- Record responses to cards in database (right now they are just inserted into the timeline)

FAQ
---
- What is debug mode? (it can be set in `config/app.yml`)?
  -  When debug mode is enabled, the app shows extra output in the browser and uses Google's Subscription Proxy https://developers.google.com/glass/tools-downloads/subscription-proxy