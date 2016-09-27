# encoding: utf-8
require "logstash/filters/base"
require "logstash/namespace"
require 'logstash/filters/docker_tools/docker_container_inspector'
require 'docker-api'

class LogStash::Filters::DockerContainerInfo < LogStash::Filters::Base

  config_name "docker_containerinfo"
  
  config :match, :validate => :hash, :default => {'container_id' => 'container_name'}, :required => true

  config :docker_api_url, :validate => :string, :default => "http://localhost:4243/", :required => true
  
  config :info_field, :validate => :string, :default => "Name", :required => true

  public
  def register
    # Add instance variables
    @inspector = LogStash::Filters::DockerTools::DockerContainerInspector.new()
    @cached = Hash.new
	Docker.url = @docker_api_url
  end # def register

  public
  def filter(event)
    return unless filter? event

	# for every match-entry...
    @match.each { |in_field,out_field|
      # using the event.set API
      event.set(out_field,resolve_from(event.get(in_field)))
    }

	# filter_matched should go in the last line of our successful code
    filter_matched(event)
  end # def filter

  private
  def resolve_from(container_id)
    if @cached.has_key?(container_id)
      return @cached[container_id]
    end

	# retrieve container-details over remote docker-api as jason-hash
    if container_id==''
		details = @inspector.inspect(nil)
	else
		details = @inspector.inspect(container_id)
	end
    return nil if details.empty?

	# if error on inspecting container
	if details.has_key?("error-message")
		return details["error-message"]
	end
	# extract field from json-information
	@cached[container_id] = get_json_field(details,@info_field) #.partition('/').last
	return @cached[container_id]
  end # def resolve_from
  
  def get_json_field(json,field)
	fieldValues = field.split("/")
	result=nil
	fieldValues.each do |field|
		if result==nil
			result=json[field]
		else
			result=result[field]
		end
	end
    return result
  end # get_json_field
end # class LogStash::Filters::DockerContainer
