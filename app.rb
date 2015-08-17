require 'rubygems' 
require 'sinatra'
require 'mongoid'
require 'yajl'
require 'byebug'
require 'eventmachine'
require './models/task'
require 'fiber'
require 'em-synchrony'

configure do
  Mongoid.load!("config/mongoid.yml")
end

before do
  content_type :json
end


get '/tasks' do
  begin
    tasks = Array.new(Task.all).to_json
  rescue => e
      error 400, e.message.to_json
    end
end

get '/sync_tasks' do
  begin
   
      (1..5).each do |n|
        tasks = Task.where(:$where => "sleep(1000) || true" ).to_json
        puts "#{n}-->>>>>>>>>>>>>============================> first_task"
      end
        

      Fiber.new{
        puts "inside fiber"
      }.resume


      
      tasks = Task.where(:$where => "sleep(5) || true" ).to_json
      puts " ------------------------==========================> second_task"
        

      
      (1..10).each do |n|
        tasks = Task.where(:$where => "sleep(1) || true" ).to_json
        puts " #{n}---------------------------------------> Third_task"
      end
       

    
  rescue => e
      error 400, e.message.to_json
    end
end

get '/async_tasks' do
  begin
    tasks = []
    EM.synchrony do

      Fiber.new{
        EM.system('ls') do
          (1..5).each do |n|
            tasks = Task.where(:$where => "sleep(1000) || true" ).to_json
            puts "#{n}-->>>>>>>>>>>>>============================> first_task"
          end
        end
      }.resume

      Fiber.new{
        EM.system('ls') do 
          tasks = Task.where(:$where => "sleep(5) || true" ).to_json
          puts " ------------------------==========================> second_task"
        end
      }.resume

      Fiber.new{
        EM.system('ls') do
          (1..10).each do |n|
            tasks = Task.where(:$where => "sleep(1) || true" ).to_json
            puts " #{n}---------------------------------------> Third_task"
          end
        end
      }.resume

    end
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
get "/tasks/:id" do
  task = Task.find(params[:id])
  if task
    task.to_json 
  else
    error 404, {:error => "task not found"}.to_json 
  end
end

# Update an individual task
put "/tasks/:id" do
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
delete '/tasks/:id' do
  task = Task.find(params[:id]) rescue nil
  task.destroy unless task.nil?
end