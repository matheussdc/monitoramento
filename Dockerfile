FROM ruby:3.4.8-alpine

RUN apk add --no-cache build-base ruby-dev

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

RUN mkdir -p database

EXPOSE 4567

CMD ["ruby", "app.rb"]
