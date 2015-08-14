require 'rubygems' 
require 'sinatra'
require 'mongoid'
require 'yajl'
require 'byebug'
require 'eventmachine'
require './models/task'

configure do
  Mongoid.load!("config/mongoid.yml")
end

before do
  content_type :json
end

get '/tasks' do
  begin
    #tasks = Array.new(Task.all).to_json
    tasks = Task.where( :$where => "sleep(5) || true" ).to_a.to_json
  rescue => e
      error 400, e.message.to_json
    end
end

# create a new task. request body to contain json
post '/tasks' do
  begin
    task = Task.new(Yajl::Parser.parse(request.body.read)["task"])
    if task.save
      task.to_json 
    else
      error 400, task.errors.to_json
    end
  rescue => e
    error 400, e.message.to_json
  end
end

# Get an individual task
get "/task/:id" do
task = Task.find(params[:id])
  if task
    task.to_json 
  else
    error 404, {:error => "task not found"}.to_json 
  end
end

# Update an individual task
put "/task/:id" do
task = Task.find(params[:id])
  if task
    begin
      task = task.update_attributes!(Yajl::Parser.parse(request.body.read)["task"])
      task.to_json
    rescue => e
      error 400, e.message.to_json
    end
  else
    error 404, "user not found".to_json
  end
end

# Delete an invidual task
delete '/task/:id' do
  task = Task.find(params[:id]) rescue nil
  task.destroy unless task.nil?
end