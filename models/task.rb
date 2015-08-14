require 'mongoid'
class Task 

  include Mongoid::Document
  include Mongoid::Timestamps

  field :description, type: String

  field :is_done, type:  Boolean, default: false
  
  validates_presence_of :description

  # helper method returns the URL for a task based on id  


  def url

    "/tasks/#{self.id}"

  end

 
  def to_json(*a)

    { 
      "id" => id,

      'obj_url'        => self.url, 

      'description' => self.description,

      'isDone'      => self.is_done 

    }.to_json(*a)

  end

 

  # keys that MUST be found in the json

  REQUIRED = [:description, :is_done]

  

  # ensure json is safe.  If invalid json is received returns nil

  def self.parse_json(body)

    json = JSON.parse(body)

    ret = { :description => json['description'], :is_done => json['isDone'] }

    return nil if REQUIRED.find { |r| ret[r].nil? }

 

    ret 

  end

  

end
