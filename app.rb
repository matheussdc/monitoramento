require 'json'
require 'sinatra'
require 'sequel'
require 'prometheus/middleware/collector'
require 'prometheus/middleware/exporter'

DB = Sequel.sqlite 'database/database.db'

use Prometheus::Middleware::Collector
use Prometheus::Middleware::Exporter

# Configurar CORS
before do
  headers 'Access-Control-Allow-Origin' => '*',
          'Access-Control-Allow-Methods' => 'GET, POST, PUT, DELETE, OPTIONS',
          'Access-Control-Allow-Headers' => 'Content-Type'
end

# Pre-flight requests
options '*' do
  status 200
end

on_start do
  DB.create_table?(:tarefas) do
    primary_key :id
    String :task, size: 60
    String :responsible, size: 30
    Integer :priority
  end

  if DB[:tarefas].empty?
    pessoas_exemplo = %w[Ana Bia Carol]
    tarefas_exemplo = ['Ajeitar cabo do ventilador', 'Bater foto do arranhão na mesa',
                       'Consertar barulho da porta da sala']
    valores_exemplo = [5, 2, 4]
    (0..2).each do |i|
      DB[:tarefas].insert(%i[task responsible priority],
                          [tarefas_exemplo[i], pessoas_exemplo[i], valores_exemplo[i]])
    end
  end
end

get '/' do
  send_file 'public/index.html'
end

get '/tarefas' do
  content_type :json
  DB[:tarefas].order(Sequel.desc(:priority)).all.to_json
end

post '/tarefas' do
  data = JSON.parse request.body.read # JSON::ParserError pode acontecer aqui

  if data['task'].nil? || data['responsible'].nil? || data['priority'].nil?
    halt 400,
         { error: 'Campos obrigatórios: task, responsible, priority' }.to_json
  end

  halt 400, { error: 'Prioridade deve ser um número' }.to_json unless data['priority'].is_a?(Integer)
  halt 400, { error: 'Tarefa muito longa (máx 60 caracteres)' }.to_json if data['task'].length > 60
  halt 400, { error: 'Responsável muito longo (máx 30 caracteres)' }.to_json if data['responsible'].length > 30

  id_novo = DB[:tarefas].insert(%i[task responsible priority], [data['task'], data['responsible'], data['priority']])

  status 201
  content_type :json
  { id: id_novo, message: 'Tarefa criada com sucesso' }.to_json
rescue JSON::ParserError
  content_type :json
  halt 400, { error: 'JSON inválido' }.to_json
end

get '/tarefas/:id' do
  tarefa = DB[:tarefas].where(id: params['id']).first
  halt 404, { error: 'Tarefa não encontrada' }.to_json if tarefa.nil?

  content_type :json
  tarefa.to_json
end

put '/tarefas/:id' do
  tarefa = DB[:tarefas].where(id: params['id']).first
  halt 404, { error: 'Tarefa não encontrada' }.to_json if tarefa.nil?

  data = JSON.parse request.body.read
  if data.key?('priority') && !data['priority'].is_a?(Integer)
    halt 400,
         { error: 'Prioridade deve ser um número' }.to_json
  end
  if data.key?('task') && data['task'].length > 60
    halt 400,
         { error: 'Tarefa muito longa (máx 60 caracteres)' }.to_json
  end
  if data.key?('responsible') && data['responsible'].length > 30
    halt 400,
         { error: 'Responsável muito longo (máx 30 caracteres)' }.to_json
  end

  DB[:tarefas].where(id: params['id']).update(data)

  status 200
  DB[:tarefas].where(id: params['id']).first.to_json
rescue JSON::ParserError
  content_type :json
  halt 400, { error: 'JSON inválido' }.to_json
end

delete '/tarefas/:id' do
  tarefa = DB[:tarefas].where(id: params['id']).first
  halt 404, { error: 'Tarefa não encontrada' }.to_json if tarefa.nil?

  DB[:tarefas].where(id: params['id']).delete
  status 204
end

configure do
  set :bind, '0.0.0.0'
  set :port, 4567
  set :static_cache_control, [:public, { max_age: 30 }]
  set :environment, :production
end
