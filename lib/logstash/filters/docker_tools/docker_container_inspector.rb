# encoding: utf-8
require 'docker-api'
require 'logger'

module LogStash::Filters::DockerTools

    class DockerContainerInspector

      public
      def initialize()
		@logger = Logger.new(STDOUT)
		@logger.level = Logger::WARN
      end

      public
      # @return [Hash] the json-hash of the container-informations over remote docker-api
      # @param [String] container_id
      def inspect(container_id)
		content={}
		if container_id == nil || container_id == '' 
			@logger.warn("empty container-id")
			content["error-message"] = "empty container-id"
			return content
		end
		begin
			@logger.debug("getting container for id '#{container_id}'")
			content = Docker::Container.get(container_id).json
			return content
		rescue Exception => ex
			@logger.fatal("exception on getting container for id '#{container_id}', type #{ex.class}, message '#{ex.message}'")
			return {"error-message" => "exception on getting container for id '#{container_id}', type #{ex.class}"}
		end
      end
    end

end
