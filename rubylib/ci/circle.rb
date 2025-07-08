require 'yaml'
require 'httparty'
require 'json'
require 'ci'
require 'ci/repo'

CIRCLE_TOKEN = -> { ENV.fetch('CIRCLE_TOKEN') { raise 'Must set `CIRCLE_TOKEN` env var' } }

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

  def status_url_for(branch:)
    pipeline = latest_pipeline_for(branch:)
    workflow = latest_workflow_for(pipeline_id: pipeline['id'])
    "https://app.circleci.com/pipelines/gh/#{Repo.current.slug}/#{pipeline['number']}/workflows/#{workflow['id']}"
  end

  def latest_jobs_for(branch:)
    pipeline = latest_pipeline_for(branch:)
    workflow = latest_workflow_for(pipeline_id: pipeline['id'])
    jobs = jobs_for(workflow_id: workflow['id'])
    started_jobs = jobs.reject {|job| !job['started_at'] }.sort_by { |job| job['started_at'] }

    step_client = CircleClientV1.new
    started_jobs.each_with_object({}) do |job, h|
      h[job['job_number']] = step_client.steps_for(job_number: job['job_number'])
    end
  end

  class Job < Ci::Job
    def self.build_url(repo_slug: Repo.current.slug, job_number:)
      "https://circleci.com/gh/#{repo_slug}/#{job_number}"
    end

    def self.from(api)
      steps = Array(api["steps"]).map { JobStep.from(_1) }
      self.new(**api.merge(steps:, url: self.build_url(job_number: api["job_number"])))
    end

    def current_step
      current_step = job_steps.find(&:running?)
      current_step ||= JobStep.completed
      current_step['name'] = truncate_name(current_step['name'])
    end
  end

  class JobStep < Ci::JobStep
    def self.complete = self.new(name: 'Completed', status: 'Completed')

    def self.from(api)
      self.new(name: api["name"], status: api.dig('actions', 0, 'status'))
    end

    def running? = status == "running" && name.downcase != 'task lifecycle'
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
