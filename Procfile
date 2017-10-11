editor:  sh -c 'cd app && bundle exec rackup -s thin config.ru -p 4000 --host 0.0.0.0'
preview: sh -c 'cd preview && bundle exec rackup -s thin config.ru -p 4001 --host 0.0.0.0'

# for development on vagrant(RAILS_ENV=development)
worker1: bundle exec rake resque:workers QUEUE=* COUNT=1