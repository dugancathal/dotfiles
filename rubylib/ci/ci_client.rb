module Ci
  class CiClient
    def latest_jobs_for(branch:) = []
    def status_url_for(branch:) = ""
  end

  class Job
    def name = 'Unknown Job'
    def failed? = false
    def steps = []

    def url = 'http://example.com'
  end

  Job = Data.define(:name, :steps, :url)

  class JobStep
    def status = 'unstarted'
    def running? = false
    def name = 'Unknown Step'
  end

  JobStep = Data.define(:name, :status) do
    def running? = status == 'running'
  end
end
