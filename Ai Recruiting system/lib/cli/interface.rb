require 'json'
require 'fileutils'

# Simplified Command Line Interface for the AI Recruiting System
class CLI
  def initialize(app)
    @app = app
  end

  def start
    loop do
      display_main_menu
      choice = get_user_input.to_i

      case choice
      when 1
        analyze_single_resume
      when 2
        screen_candidates
      when 3
        generate_interview_questions
      when 4
        view_saved_results
      when 0
        puts "\n👋 Thank you for using AI Recruiting System!"
        break
      else
        puts "\n❌ Invalid choice. Please try again."
      end

      puts "\nPress Enter to continue..."
      gets
    end
  end

  private

  def display_main_menu
    puts "\n" + "="*50
    puts "🤖 AI RECRUITING SYSTEM"
    puts "="*50
    puts "CORE FEATURES:"
    puts "1. 📄 Analyze Resume"
    puts "2. 🔍 Screen Candidate"
    puts ""
    puts "UTILITIES:"
    puts "3. ❓ Interview Questions"
    puts "4. 💾 View Results"
    puts "0. 🚪 Exit"
    puts "="*50
    print "Choose an option (0-4): "
  end

  def get_user_input
    input = gets.chomp.strip
    puts ""
    input
  end

  def analyze_single_resume
    puts "📄 RESUME ANALYSIS"
    puts "-" * 17
    
    resume_file = get_resume_file
    return unless resume_file
    
    puts "\n🔄 Analyzing resume..."
    result = @app.parse_resume(resume_file)
    
    if result[:success]
      puts "\n✅ Analysis completed!"
      puts "Candidate: #{result[:candidate_name] || 'Unknown'}"
      puts "Skills found: #{result[:extracted_data][:skills]&.count || 0}"
      puts "Experience: #{result[:extracted_data][:total_years_experience] || 0} years"
      puts "Email: #{result[:extracted_data][:contact_info][:email]}"
      
      if result[:ai_analysis] && result[:ai_analysis].length > 20
        puts "\n🤖 AI Analysis:"
        puts result[:ai_analysis][0..300] + "..."
      end
      
      save_result(result, "resume_analysis")
    else
      puts "❌ Analysis failed: #{result[:error]}"
    end
  end

  def screen_candidates
    puts "🔍 CANDIDATE SCREENING"
    puts "-" * 22
    
    resume_file = get_resume_file
    return unless resume_file
    
    job_description = get_job_description
    return unless job_description
    
    puts "\n🔄 Processing and screening..."
    resume_result = @app.parse_resume(resume_file)
    return unless resume_result[:success]
    
    screening_result = @app.screen_candidate_basic(resume_result, job_description)
    
    puts "\n✅ Screening completed!"
    puts "Candidate: #{resume_result[:candidate_name] || 'Unknown'}"
    
    if screening_result[:screening_analysis] && screening_result[:screening_analysis].length > 20
      puts "\n📊 Screening Analysis:"
      puts screening_result[:screening_analysis][0..300] + "..."
    end
    
    save_result(screening_result, "candidate_screening")
  end

  def generate_interview_questions
    puts "❓ INTERVIEW QUESTIONS"
    puts "-" * 21
    
    resume_file = get_resume_file
    return unless resume_file
    
    job_description = get_job_description
    return unless job_description
    
    puts "\n🔄 Generating interview questions..."
    resume_result = @app.parse_resume(resume_file)
    return unless resume_result[:success]
    
    questions = @app.generate_interview_questions(job_description, resume_result)
    
    puts "\n✅ Interview questions generated!"
    puts "Candidate: #{resume_result[:candidate_name] || 'Unknown'}"
    
    if questions && questions.length > 20
      puts "\n❓ Suggested Questions:"
      puts questions[0..400] + "..."
    end
    
    save_result({
      candidate_name: resume_result[:candidate_name],
      questions: questions,
      job_description: job_description
    }, "interview_questions")
  end

  def view_saved_results
    puts "💾 SAVED RESULTS"
    puts "-" * 15
    
    data_files = Dir.glob("data/*.json").sort_by { |f| File.mtime(f) }.reverse

    if data_files.empty?
      puts "No saved results found in the 'data/' directory."
      return
    end

    puts "Available saved results:"
    data_files.first(10).each_with_index do |file, index|
      puts "#{index + 1}. #{File.basename(file)}"
    end

    print "\nEnter the number of the file to view (or 0 to cancel): "
    choice = get_user_input.to_i

    if choice > 0 && choice <= [data_files.length, 10].min
      display_saved_result(data_files[choice - 1])
    elsif choice != 0
      puts "❌ Invalid choice."
    end
  end

  def get_resume_file
    puts "Enter path to resume file (e.g., resumes/sample_resume.txt):"
    print "Resume file: "
    file_path = get_user_input

    unless File.exist?(file_path)
      puts "❌ File not found: #{file_path}"
      return nil
    end

    file_path
  end

  def get_job_description
    puts "Enter path to job description file or type 'manual' to enter directly:"
    print "Job description source: "
    source = get_user_input.downcase

    if source == 'manual'
      puts "\nEnter job description (type 'END' on a new line to finish):"
      lines = []
      loop do
        line = gets.chomp
        break if line == 'END'
        lines << line
      end
      lines.join("\n")
    else
      unless File.exist?(source)
        puts "❌ File not found: #{source}"
        return nil
      end
      File.read(source, encoding: 'UTF-8')
    end
  end

  def save_result(data, type)
    timestamp = Time.now.strftime("%Y%m%d_%H%M%S")
    filename = "#{type}_#{timestamp}.json"
    filepath = "data/#{filename}"
    
    Dir.mkdir("data") unless Dir.exist?("data")
    
    File.write(filepath, JSON.pretty_generate(data))
    puts "💾 Results saved to: #{filepath}"
  end

  def display_saved_result(file_path)
    begin
      data = JSON.parse(File.read(file_path), symbolize_names: true)
      filename = File.basename(file_path)

      puts "\n📄 VIEWING: #{filename}"
      puts "="*50
      
      # Show key information instead of full JSON
      if data[:candidate_name]
        puts "Candidate: #{data[:candidate_name]}"
      end
      
      if data[:success]
        puts "Status: Success"
      end
      
      puts "\nFull data:"
      puts JSON.pretty_generate(data)[0..1000] + "..."
      
    rescue => e
      puts "❌ Error reading file: #{e.message}"
    end
  end
end
