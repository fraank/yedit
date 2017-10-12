# yedit - the web editor

the web editor for handling multiple static website projects controlled by jekyll.


## Key Features

- multi-project - manage multiple websites, switch projects to develop and preview in ui
- direct deploy - deploy to your cdn, over ftp / ssh
- file driven - no database needed
- 'take a away' - all data can be exported at any time
- every feature available through web-interface


## Principles for building this package:

Keeping the things as easy as possible:

 - minimum gem dependencies
 - no big frameworks
 - maximum performance
 - easy to use ui
 - fasten up development and deployment


Due to this reasons we didn't use any big js frameworks, rails, or outstanding css-frameworks.


Adding themes:
Use the interface (beta) or just make a 'git clone #repo' in ./usr/themes.

Adding plugins:
Use the interface (beta) or just make a 'git clone #repo' in ./usr/plugins.


## Quick run with docker:

    $ docker-compose up

## Run tests

    $ docker-compose -f docker-compose-testing.yml run editor /bin/bash -l -c "bundle exec rspec"

## Update gems

To update the projects bundle execute:

    $ docker-compose build

## Update docs

To update the projects docs:

    $ docker-compose run editor /bin/bash -l -c "bundle exec yard"
