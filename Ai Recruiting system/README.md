# AI Recruiting System

A streamlined Ruby-based AI recruiting system powered by RubyLLM for intelligent resume analysis and candidate screening.

## 🚀 Quick Start

1. **Install dependencies:**
   ```bash
   bundle install
   ```

2. **Configure API keys:**
   ```bash
   cp env.example .env
   # Add your OPENAI_API_KEY or OPENROUTER_API_KEY
   ```

3. **Run the application:**
   ```bash
   ruby main.rb
   ```

## ✨ Features

- **📄 Resume Analysis** - Parse .txt resume files with AI
- **🔍 Candidate Screening** - AI-powered screening against job requirements  
- **🎯 Job Matching** - Intelligent candidate-to-job matching with scores
- **🤖 Comprehensive Evaluation** - Deep candidate analysis using RubyLLM agents
- **📊 Batch Processing** - Analyze multiple candidates simultaneously
- **💾 Data Persistence** - Save all results as JSON files

## 📋 Usage

Choose from 8 menu options:
1. Analyze Resume - Process a single .txt resume file
2. Screen Candidate - Basic screening against job requirements
3. Match to Job - Match candidates to job positions
4. Comprehensive Evaluation - Full AI analysis using multiple agents
5. Batch Analysis - Process multiple candidates at once
6. Background Analysis - Detailed candidate evaluation
7. Interview Questions - Generate targeted questions
8. View Results - Review saved analysis

## 🏗️ Architecture

```
lib/
├── agents/          # RubyLLM AI agents (5 specialized tools)
├── services/        # Resume parsing and candidate screening
├── clients/         # AI API client (OpenAI/OpenRouter)
├── cli/             # Command-line interface
├── ai_recruiting_system.rb    # Main application
└── recruiting_coordinator.rb  # RubyLLM orchestration
```

## 🤖 AI Agents

- **ResumeAnalysisAgent** - Analyzes resume content
- **CandidateScreeningAgent** - Screens against requirements  
- **JobMatchingAgent** - Matches candidates with scoring
- **InterviewStrategyAgent** - Generates interview questions
- **CandidateBackgroundAgent** - Comprehensive evaluation

## 📄 File Support

- **Supported**: .txt files only (reliable across all systems)
- **Note**: Convert PDF/DOCX resumes to .txt format for processing

## ⚙️ Requirements

- Ruby 3.0+
- OpenAI or OpenRouter API key
- Dependencies: `ruby_llm`, `httparty`, `dotenv`, `json`

## 🎯 Perfect For

HR teams and recruiters who need intelligent candidate analysis without complexity - clean, focused, and production-ready!