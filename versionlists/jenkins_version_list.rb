require 'pry'

class JenkinsVersionList < BaseVersionList
  def initialize(artifact, baseUrl, job)
    super(artifact)
    @baseUrl = baseUrl
    @job = job
    @input = JenkinsInput.new(artifact)
  end

  def get_versions
    result = BaseVersionList.get_json "#{@baseUrl}/job/#{@job}/api/json"

    return result[:builds].map do |build|
      [
          build[:number],
          build[:url]
      ]
    end
  end

  def get_version(id)
    @input.parse BaseVersionList.get_json id[1] + 'api/json'
  end
end