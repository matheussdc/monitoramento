require 'json'
require 'sinatra'
require 'sequel'

DB = Sequel.sqlite 'database.db'

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
  return 'Hello!'
end

get '/tarefas' do
  DB[:tarefas].all.to_json
end

post '/tarefas' do
  data = JSON.parse request.body.read
  id_novo = DB[:tarefas].insert(%i[task responsible priority], [data['task'], data['responsible'], data['priority']])
  status 201
  { id: id_novo }.to_json
end

get '/tarefas/:id' do
  DB[:tarefas].where(id: params['id']).all.to_json
end

put '/tarefas/:id' do
  data = JSON.parse request.body.read
  DB[:tarefas].where(id: params['id']).update(data)
  status 201
  DB[:tarefas].where(id: params['id']).all.to_json
end

delete '/tarefas/:id' do
  DB[:tarefas].where(id: params['id']).delete
  status 201
end

configure do
  set :port, 4567
end
