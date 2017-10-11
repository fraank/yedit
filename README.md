# yedit

The website editor for handling multiple static websites managed by jekyll.


## Principles for builing this package:

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
