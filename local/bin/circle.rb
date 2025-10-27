# ===dotfiles===
require 'yaml'
require 'httparty'
require 'json'
require_relative './repo'

CIRCLE_TOKEN = ENV.fetch('CIRCLE_TOKEN') { raise 'Must set `CIRCLE_TOKEN` env var' }

def current_branch(argv = ARGV)
  argv.first || `git symbolic-ref HEAD`.strip.split('refs/heads/').last
end

class CircleClient
  include HTTParty

  base_uri 'https://circleci.com/api/v2'
  headers 'Circle-Token' => CIRCLE_TOKEN, 'Accept' => 'application/json'

  def pipelines_for(branch:)
    self.class.get("/project/gh/#{Repo.current.slug}/pipeline", query: { branch: })
  end

  def latest_pipeline_for(branch:)
    pipelines_for(branch:)['items'].first
  end

  def workflows_for(pipeline_id:)
    self.class.get("/pipeline/#{pipeline_id}/workflow")
  end

  def latest_workflow_for(pipeline_id:)
    workflows_for(pipeline_id:)['items'].first
  end

  def jobs_for(workflow_id:)
    self.class.get("/workflow/#{workflow_id}/job")['items']
  end
end 

class CircleClientV1
  include HTTParty

  base_uri 'https://circleci.com/api/v1.1'
  headers 'Circle-Token' => CIRCLE_TOKEN, 'Accept' => 'application/json'

  def steps_for(job_number:)
    self.class.get("/project/gh/#{Repo.current.slug}/#{job_number}")['steps']
  end
end
