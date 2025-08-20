require_relative 'clients/ai_client'
require_relative 'services/resume_analyzer'
require_relative 'services/candidate_screener'
require_relative 'cli/interface'

# Main AI Recruiting System application class
class AIRecruitingSystem
  def initialize
    @ai_client = AIClient.new
    @resume_analyzer = ResumeAnalyzer.new(@ai_client)
    @candidate_screener = CandidateScreener.new(@ai_client)
    @cli = CLI.new(self)
  end

  def run
    puts "🤖 AI Recruiting System"
    puts "======================="
    puts "OpenRouter API Key: #{ENV['OPENROUTER_API_KEY'] ? '✅ Configured' : '❌ Missing'}"
    puts ""

    @cli.start
  end

  # Core functionality methods
  def parse_resume(file_path)
    @resume_analyzer.analyze(file_path)
  end

  def screen_candidate_basic(candidate_data, job_requirements)
    @candidate_screener.screen(candidate_data, job_requirements)
  end

  def generate_interview_questions(job_description, resume_data)
    @ai_client.generate_interview_questions(job_description, resume_data)
  end

  # Utility methods
  def save_results(data, filename)
    timestamp = Time.now.strftime("%Y%m%d_%H%M%S")
    filepath = "data/#{filename}_#{timestamp}.json"
    
    Dir.mkdir('data') unless Dir.exist?('data')
    
    File.write(filepath, JSON.pretty_generate(data))
    filepath
  end
end