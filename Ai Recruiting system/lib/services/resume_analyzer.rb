require 'json'

# Simplified Resume Analyzer service for parsing resumes
class ResumeAnalyzer
  def initialize(ai_client)
    @ai_client = ai_client
  end

  def analyze(file_path)
    puts "📄 Analyzing resume: #{File.basename(file_path)}"
    
    # Extract text from file (only supports .txt files)
    resume_text = extract_text_from_file(file_path)
    
    if resume_text.nil? || resume_text.strip.empty?
      return {
        success: false,
        error: "Could not extract text from resume file or file is empty",
        file_path: file_path
      }
    end

    # Get AI analysis of the resume
    ai_analysis = @ai_client.analyze_resume_content(resume_text)
    
    # Extract basic structured data
    extracted_data = extract_basic_data(resume_text)
    
    # Return structured result
    analysis_result = {
      success: true,
      file_path: file_path,
      candidate_name: extracted_data[:candidate_name],
      resume_text: resume_text,
      ai_analysis: ai_analysis,
      extracted_data: extracted_data,
      timestamp: Time.now.to_s
    }

    puts "✅ Resume analysis completed for #{analysis_result[:candidate_name] || 'Unknown Candidate'}"
    analysis_result
  end

  def batch_analyze(resume_directory)
    puts "📁 Starting batch analysis of resumes in: #{resume_directory}"
    
    resume_files = Dir.glob("#{resume_directory}/**/*.txt")
    
    if resume_files.empty?
      puts "⚠️  No .txt resume files found in #{resume_directory}"
      return []
    end

    puts "📄 Found #{resume_files.length} resume files to analyze"
    
    results = []
    resume_files.each_with_index do |file, index|
      puts "\n[#{index + 1}/#{resume_files.length}] Processing: #{File.basename(file)}"
      result = analyze(file)
      results << result
    end

    puts "\n✅ Batch analysis completed. Processed #{results.length} resumes"
    results
  end

  private

  def extract_text_from_file(file_path)
    case File.extname(file_path).downcase
    when '.txt'
      File.read(file_path, encoding: 'UTF-8')
    else
      puts "⚠️  Only .txt files are supported. Please convert your resume to .txt format"
      nil
    end
  rescue => e
    puts "❌ Error reading file #{file_path}: #{e.message}"
    nil
  end

  def extract_basic_data(text)
    lines = text.split("\n").map(&:strip).reject(&:empty?)
    
    # Basic extraction using simple patterns
    {
      candidate_name: extract_name(lines),
      skills: extract_skills_simple(text),
      total_years_experience: extract_experience_years(text),
      education: extract_education_simple(text),
      contact_info: extract_contact_simple(text),
      work_experience: extract_work_simple(text)
    }
  end

  def extract_name(lines)
    # Try to find name in first few lines
    lines.first(3).each do |line|
      # Skip lines that look like headers or contact info
      next if line.match?(/resume|cv|curriculum|email|phone|@|\d{3}[-\s]\d{3}/i)
      next if line.length < 3 || line.length > 50
      
      # Look for lines with 2-4 capitalized words (likely names)
      if line.match?(/^[A-Z][a-z]+\s+[A-Z][a-z]+/)
        return line.strip
      end
    end
    
    "Unknown"
  end

  def extract_skills_simple(text)
    # Look for common skill patterns
    skills = []
    
    # Common programming languages and technologies
    tech_skills = %w[
      ruby rails javascript react python java c# php html css sql
      postgresql mysql mongodb redis aws docker kubernetes git
      angular vue node.js typescript swift kotlin android ios
    ]
    
    tech_skills.each do |skill|
      if text.match?(/\b#{Regexp.escape(skill)}\b/i)
        skills << skill.downcase
      end
    end
    
    skills.uniq
  end

  def extract_experience_years(text)
    # Look for experience patterns like "5 years", "3+ years"
    matches = text.scan(/(\d+)[\+\s]*years?\s+(?:of\s+)?experience/i)
    
    if matches.any?
      matches.map { |match| match[0].to_f }.max
    else
      # Try to estimate from work history
      estimate_from_work_history(text)
    end
  end

  def estimate_from_work_history(text)
    # Simple estimation based on date patterns
    current_year = Time.now.year
    years = text.scan(/\b(19|20)\d{2}\b/).map { |match| match.join.to_i }
    
    if years.any?
      years.uniq!
      years.select! { |year| year >= 1990 && year <= current_year }
      return 0 if years.empty?
      
      earliest = years.min
      latest = years.max
      
      # Estimate experience span
      [current_year - earliest, latest - earliest].max.to_f
    else
      0.0
    end
  end

  def extract_education_simple(text)
    education = []
    
    # Look for degree patterns
    degree_patterns = [
      /\b(bachelor|master|phd|doctorate|mba|bs|ms|ba|ma)\s+(?:of\s+)?(?:science\s+)?(?:in\s+)?([^,\n]+)/i,
      /\b(associate|diploma)\s+(?:in\s+)?([^,\n]+)/i
    ]
    
    degree_patterns.each do |pattern|
      text.scan(pattern) do |degree_type, field|
        education << {
          degree: "#{degree_type.capitalize} #{field.strip}",
          institution: "Institution not specified"
        }
      end
    end
    
    education
  end

  def extract_contact_simple(text)
    contact = {}
    
    # Email
    email_match = text.match(/\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b/)
    contact[:email] = email_match[0] if email_match
    
    # Phone
    phone_match = text.match(/(\(?\d{3}\)?[-.\s]?\d{3}[-.\s]?\d{4})/)
    contact[:phone] = phone_match[0] if phone_match
    
    # Location (city, state pattern)
    location_match = text.match(/([A-Z][a-z]+,\s*[A-Z]{2})|([A-Z][a-z]+\s*,\s*[A-Z][a-z]+)/)
    contact[:location] = location_match[0] if location_match
    
    contact
  end

  def extract_work_simple(text)
    # Simple work experience extraction
    experiences = []
    
    # Look for job title patterns followed by company names
    text.scan(/^(.+?)(?:\s+at\s+|\s+@\s+|\s+-\s+)(.+?)$/i) do |title, company|
      next if title.length > 100 || company.length > 100
      
      experiences << {
        title: title.strip,
        company: company.strip,
        duration: "Duration not specified"
      }
    end
    
    experiences.first(5) # Limit to 5 most recent
  end
end