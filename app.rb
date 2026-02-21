require 'sinatra'

get '/' do
  return "Hello!"
end

configure do
  set :port, 4567
end
