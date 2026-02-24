require 'json'
require 'sinatra'
require 'sequel'

DB = Sequel.sqlite 'database.db'

on_start do
  puts 'Verificando existência do banco de dados...'

  DB.create_table?(:pessoas) do
    primary_key :id
    String :name, size: 30
  end

  DB.create_table?(:transacoes) do
    primary_key :id
    foreign_key :pessoa_id, :pessoas
    Float :value
  end

  if DB[:pessoas].empty?
    puts 'Populando tabela Pessoas...'
    pessoas_exemplo = %w[Ana Bia Carol]
    DB[:pessoas].import([:name], pessoas_exemplo)
  else
    puts 'Tabela Pessoas já populada'
  end
end

get '/' do
  return 'Hello!'
end

get '/pessoas' do
  content_type :json
  return DB[:pessoas].all.to_json
end

configure do
  set :port, 4567
end
