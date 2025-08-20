require 'httparty'
require 'json'

# Simplified AI Client for interacting with AI providers
class AIClient
  include HTTParty
  
  def initialize
    @openrouter_key = ENV['OPENROUTER_API_KEY']
    
    if @openrouter_key
      @provider = :openrouter
      @base_url = 'https://openrouter.ai/api/v1'
      @headers = {
        'Authorization' => "Bearer #{@openrouter_key}",
        'Content-Type' => 'application/json',
        'HTTP-Referer' => 'https://github.com/ai-recruiting-system',
        'X-Title' => 'AI Recruiting System'
      }
    else
      raise "Missing OpenRouter API key. Please set OPENROUTER_API_KEY environment variable."
    end
  end

  # Core AI methods used by services
  def analyze_resume_content(resume_text)
    call_ai_api("Analyze this resume and extract key information:\n\n#{resume_text}")
  end

  def screen_candidate(resume_data, job_requirements)
    call_ai_api("Screen this candidate against job requirements:\n\nCandidate:\n#{resume_data}\n\nRequirements:\n#{job_requirements}")
  end

  def generate_interview_questions(job_description, resume_data)
    call_ai_api("Generate interview questions for this candidate:\n\nJob:\n#{job_description}\n\nCandidate:\n#{resume_data}")
  end

  # Optimized OpenRouter API call
  def call_ai_api(prompt)
    return "AI analysis not available (no API key configured)" unless api_configured?
    
    # Use Claude for better recruiting analysis
    model = 'anthropic/claude-3-haiku'
    
    body = {
      model: model,
      messages: [
        {
          role: 'system',
          content: 'You are an expert HR professional and recruitment specialist. Provide clear, structured analysis.'
        },
        {
          role: 'user',
          content: prompt
        }
      ],
      max_tokens: 1500,
      temperature: 0.3
    }

    begin
      response = self.class.post(
        "#{@base_url}/chat/completions",
        headers: @headers,
        body: body.to_json,
        timeout: 30
      )

      if response.success?
        content = response.dig('choices', 0, 'message', 'content')&.strip
        content || "No response received"
      else
        "Error: #{response.code} - #{response.message}"
      end
    rescue => e
      "Error calling OpenRouter API: #{e.message}"
    end
  end

  def api_configured?
    @openrouter_key
  end
end