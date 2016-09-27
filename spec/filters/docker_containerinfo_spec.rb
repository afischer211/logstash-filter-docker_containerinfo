# encoding: utf-8
require 'spec_helper'
require "logstash/filters/docker_containerinfo"
require 'rspec/mocks'
require 'json'

describe LogStash::Filters::DockerContainerInfo do
  let(:inspector) { double 'LogStash::Filters::DockerTools::DockerContainerInspector' }
  let(:docker) { double 'Docker::Container' }
  

  #before do
  #  allow(LogStash::Filters::DockerTools::DockerContainerInspector).to receive(:new).and_return(inspector)
  #end

  describe "lookup name for id with caching" do
    let(:config) do <<-CONFIG
      filter {
        docker_containerinfo {
          match => { 'container_id' => 'container_name' }
		  docker_api_url => 'http://localhost:4243/'
		  info_field => 'Name'
        }
      }
    CONFIG
    end

    before do
	  allow(LogStash::Filters::DockerTools::DockerContainerInspector).to receive(:new).and_return(inspector)
      content = File.new(File.join(File.dirname(__FILE__),'container_logstash.json')).read()
      # Due to caching of the Docker findings, the inspector should only be consulted once
      # since the sample includes the same container ID both times
      expect(inspector).to receive(:inspect).once
                               .with('bd30193a3b9d')
                               .and_return(JSON.parse(content).first)
    end

    sample([{'seq' => 1, 'container_id' => 'bd30193a3b9d'}, {'seq' => 2, 'container_id' => 'bd30193a3b9d'}]) do
      subject.each do |e|
        expect(e).to include('container_name')
        expect(e.get('container_name')).to eq('/logstash')
      end
    end
  end
  describe "lookup image-id for container-id with caching" do
    let(:config) do <<-CONFIG
      filter {
        docker_containerinfo {
          match => { 'container_id' => 'container_imageid' }
		  docker_api_url => 'http://localhost:4243/'
		  info_field => 'Image'
        }
      }
    CONFIG
    end

    before do
	  allow(LogStash::Filters::DockerTools::DockerContainerInspector).to receive(:new).and_return(inspector)
      content = File.new(File.join(File.dirname(__FILE__),'container_logstash.json')).read()
      # Due to caching of the Docker findings, the inspector should only be consulted once
      # since the sample includes the same container ID both times
      expect(inspector).to receive(:inspect).once
                               .with('bd30193a3b9d')
                               .and_return(JSON.parse(content).first)
    end

    sample([{'seq' => 1, 'container_id' => 'bd30193a3b9d'}, {'seq' => 2, 'container_id' => 'bd30193a3b9d'}]) do
      subject.each do |e|
        expect(e).to include('container_imageid')
        expect(e.get('container_imageid')).to eq('262c2f8dd6f8a34822efe638b5cb9798b31bfee61201e4c14f05067e72373b86')
      end
    end
  end
  describe "lookup configured image-name for container-id with caching" do
    let(:config) do <<-CONFIG
      filter {
        docker_containerinfo {
          match => { 'container_id' => 'container_image' }
		  docker_api_url => 'http://localhost:4243/'
		  info_field => 'Config/Image'
        }
      }
    CONFIG
    end

    before do
	  allow(LogStash::Filters::DockerTools::DockerContainerInspector).to receive(:new).and_return(inspector)
      content = File.new(File.join(File.dirname(__FILE__),'container_logstash.json')).read()
      # Due to caching of the Docker findings, the inspector should only be consulted once
      # since the sample includes the same container ID both times
      expect(inspector).to receive(:inspect).once
                               .with('bd30193a3b9d')
                               .and_return(JSON.parse(content).first)
    end

    sample([{'seq' => 1, 'container_id' => 'bd30193a3b9d'}, {'seq' => 2, 'container_id' => 'bd30193a3b9d'}]) do
      subject.each do |e|
        expect(e).to include('container_image')
        expect(e.get('container_image')).to eq('itzg/logstash')
      end
    end
  end
  describe "lookup configured LogConfig-Type for container-id with caching" do
    let(:config) do <<-CONFIG
      filter {
        docker_containerinfo {
          match => { 'container_id' => 'container_logtype' }
		  docker_api_url => 'http://localhost:4243/'
		  info_field => 'HostConfig/LogConfig/Type'
        }
      }
    CONFIG
    end

    before do
	  allow(LogStash::Filters::DockerTools::DockerContainerInspector).to receive(:new).and_return(inspector)
      content = File.new(File.join(File.dirname(__FILE__),'container_logstash.json')).read()
      # Due to caching of the Docker findings, the inspector should only be consulted once
      # since the sample includes the same container ID both times
      expect(inspector).to receive(:inspect).once
                               .with('bd30193a3b9d')
                               .and_return(JSON.parse(content).first)
    end

    sample([{'seq' => 1, 'container_id' => 'bd30193a3b9d'}, {'seq' => 2, 'container_id' => 'bd30193a3b9d'}]) do
      subject.each do |e|
        expect(e).to include('container_logtype')
        expect(e.get('container_logtype')).to eq('syslog')
      end
    end
  end

  describe "check error-handling for empty container-id" do
    let(:config) do <<-CONFIG
      filter {
        docker_containerinfo {
          match => { 'container_id' => 'container_name' }
		  docker_api_url => 'http://localhost:4243/'
		  info_field => 'Name'
        }
      }
    CONFIG
    end

    before do
	  #allow(LogStash::Filters::DockerTools::DockerContainerInspector).to receive(:new).and_return(inspector)
      #expect(docker).to receive(:get)
      #                         .with('')
      #                         .and_return(nil)
    end

    sample([{'seq' => 1, 'container_id' => ''}, {'seq' => 2, 'container_id' => ''}]) do
      subject.each do |e|
        expect(e).to include('container_name')
        expect(e.get('container_name')).to eq('empty container-id')
      end
    end
  end
  describe "check error-handling for exceptions on container-inspection" do
    let(:config) do <<-CONFIG
      filter {
        docker_containerinfo {
          match => { 'container_id' => 'container_name' }
		  docker_api_url => 'http://localhost:4243/'
		  info_field => 'Name'
        }
      }
    CONFIG
    end

    before do
	  #allow(LogStash::Filters::DockerTools::DockerContainerInspector).to receive(:new).and_return(inspector)
      #expect(docker).to receive(:get)
      #                         .with('')
      #                         .and_return(nil)
    end

    sample([{'seq' => 1, 'container_id' => 'abc'}, {'seq' => 2, 'container_id' => 'def'}]) do
      subject.each do |e|
        expect(e).to include('container_name')
        expect(e.get('container_name')).to start_with("exception on getting container for id '#{e.get('container_id')}'")
      end
    end
  end
end
