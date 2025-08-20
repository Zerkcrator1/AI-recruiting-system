#!/usr/bin/env ruby

begin
  require 'bundler/setup'
rescue LoadError
  puts "❌ Bundler not found. Please install gems:"
  puts "   gem install bundler"
  puts "   bundle install"
  exit 1
end

begin
  require 'dotenv/load'
rescue LoadError
  # Continue without dotenv if not available
end

require_relative 'lib/ai_recruiting_system'

# Run the application
if __FILE__ == $0
  # Configure RubyLLM for OpenRouter
  begin
    require 'ruby_llm'
    
    if ENV['OPENROUTER_API_KEY']
      RubyLLM.configure do |config|
        config.openrouter_api_key = ENV['OPENROUTER_API_KEY']
      end
      
      # Optimized RubyLLM tools for recruiting
      class RecruitingAnalyzer < RubyLLM::Tool
        description "Analyzes resumes and candidates for recruiting"
        param :candidate_data, desc: "Candidate resume data"
        param :job_requirements, desc: "Job requirements to match against"

        def execute(candidate_data:, job_requirements:)
          RubyLLM.chat(model: 'anthropic/claude-3-haiku')
                 .ask("Analyze this candidate against job requirements:\n\nCandidate: #{candidate_data}\n\nJob: #{job_requirements}")
                 .content
        end
      end

      class InterviewGenerator < RubyLLM::Tool
        description "Generates tailored interview questions"
        param :candidate_profile, desc: "Candidate background and skills"
        param :role_description, desc: "Job role description"

        def execute(candidate_profile:, role_description:)
          RubyLLM.chat(model: 'anthropic/claude-3-sonnet')
                 .ask("Generate 5-7 interview questions for:\n\nCandidate: #{candidate_profile}\n\nRole: #{role_description}")
                 .content
        end
      end

      # Initialize recruiting coordinator
      begin
        recruiting_coordinator = RubyLLM.chat.with_tools(RecruitingAnalyzer, InterviewGenerator)
        puts "🚀 RubyLLM recruiting tools configured (RecruitingAnalyzer, InterviewGenerator)"
      rescue => e
        puts "⚠️  RubyLLM coordinator setup failed: #{e.message}"
      end
    end
  rescue LoadError
    puts "⚠️  RubyLLM not available - continuing with basic features"
  rescue => e
    puts "⚠️  RubyLLM setup failed: #{e.message}"
  end

  # Start the main application
  begin
    app = AIRecruitingSystem.new
    app.run
  rescue => e
    puts "❌ Error: #{e.message}"
    puts "💡 Ensure OPENROUTER_API_KEY is set and run 'bundle install'"
    exit 1
  end
end