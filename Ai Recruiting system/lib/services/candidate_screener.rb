require 'json'

# Simplified Candidate Screener service
class CandidateScreener
  def initialize(ai_client)
    @ai_client = ai_client
  end

  def screen(candidate_data, job_requirements)
    puts "🔍 Screening candidate: #{candidate_data[:candidate_name] || 'Unknown'}"
    
    # Use AI client for basic screening
    screening_result = @ai_client.screen_candidate(
      prepare_candidate_summary(candidate_data), 
      job_requirements
    )
    
    # Return simplified result
    {
      candidate_name: candidate_data[:candidate_name],
      candidate_file: candidate_data[:file_path],
      job_requirements: job_requirements,
      screening_analysis: screening_result,
      timestamp: Time.now.to_s
    }
  end

  private

  def prepare_candidate_summary(candidate_data)
    return "No candidate data available" unless candidate_data[:extracted_data]
    
    summary = []
    data = candidate_data[:extracted_data]
    
    summary << "Candidate: #{candidate_data[:candidate_name] || 'Unknown'}"
    summary << "Experience: #{data[:total_years_experience] || 'Not specified'} years"
    summary << "Skills: #{data[:skills]&.join(', ') || 'Not specified'}"
    
    if data[:education]&.any?
      summary << "Education: #{data[:education].first[:degree]} from #{data[:education].first[:institution]}"
    end
    
    summary.join("\n")
  end
end