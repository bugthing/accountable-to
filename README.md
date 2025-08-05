# 🎯 **Accountable To**

> *Where Goals Meet AI-Powered Accountability*

[![Rails 8.0](https://img.shields.io/badge/Rails-8.0-red.svg)](https://rubyonrails.org/)
[![Ruby](https://img.shields.io/badge/Ruby-3.3+-red.svg)](https://www.ruby-lang.org/)
[![AI Powered](https://img.shields.io/badge/AI-OpenAI%20%7C%20Local%20LLM-blue.svg)](https://openai.com/)
[![Tests](https://img.shields.io/badge/Tests-Comprehensive-green.svg)](#testing)

A sophisticated **Ruby on Rails 8** application that combines modern web development with AI to help users achieve their goals through intelligent accountability systems.

---

## 🌟 **Why This Project Stands Out**

> **Portfolio Showcase**: This demonstrates using an array of Rails features with best practices to create a neat till application.

### 🚀 **Modern Rails Architecture**
- **[Rails 8.0](app/controllers/)** with latest conventions and solid stack
- **[Comprehensive test suite](test/)** with 90%+ coverage across unit, integration, and system tests
- **[Background job processing](app/jobs/)** with intelligent AI title generation
- **[Email integration](app/mailboxes/)** using Action Mailbox for two-way communication

### 🎨 **Professional Frontend**
- **[Responsive design](app/assets/stylesheets/)** with well organisation, modern CSS
- **[Stimulus controllers](app/javascript/controllers/)** for interactive features, nice clean controllers
- **Mobile-first** approach ensuring good UX across devices

### 🤖 **AI Integration Excellence**
- **Multi-model AI support** (OpenAI + local LLM via [ruby-llm](config/initializers/ruby_llm.rb))
- **[Smart goal title generation](app/jobs/generate_goal_title_job.rb)** from descriptions
- **[Intelligent response processing](app/jobs/generate_assistant_response_job.rb)** for user interactions

### ⚡ **DevOps & Deployment**
- **[Kamal deployment](config/deploy.yml)** for easy containerized deploys
- **[Terraform infrastructure](config/provision/)** to bootstrap an CoreOS server to deploy on to
- **[Docker containerization](Dockerfile)** for consistent, portable environments

---

## 📋 **Key Features Demonstrated**

### 🏗️ **Architecture & Code Quality**
- **[MVC Pattern](app/)** - Clean separation of concerns with organized controllers, models, and views
- **[Service Objects](app/services/)** - Business logic encapsulation for complex operations
- **[Job Processing](app/jobs/)** - Asynchronous background processing to off-load what we can
- **[Email Handling](app/mailboxes/)** - Two-way email communication with Action Mailbox

### 🧪 **Testing Excellence**
- **[System Tests](test/system/)** - Full user journey testing with Capybara. Top of the testing Pyramid
- **[Integration Tests](test/service/)** - Goal LLM interactions are covered using VCR to mock API calls
- **[Job Tests](test/jobs/)** - Background job processing verification
- **[Mailer Tests](test/mailers/)** - Email delivery and content testing
- **[Model Tests](test/models/)** - Comprehensive validation, data and behaviour testing

### 🎨 **Modern Frontend**
- **[CSS Architecture](app/assets/stylesheets/)** - Organized, maintainable stylesheets
- **[JavaScript Integration](app/javascript/)** - Stimulus controllers for enhanced UX

### 🚀 **Production Ready**
- **[CI Pipeline](.gitlab-ci.yml)** - Automated testing and deployment
- **[Database Migrations](db/migrate/)** - Well-structured schema evolution
- **[Configuration Management](config/)** - Environment-specific configs

---

## 🛠️ **Quick Start**

### Prerequisites
- Ruby 3.3+
- Bundler
- SQLite3

### Installation

```bash
# Clone and install dependencies
git clone git@gitlab.com:bugthing/accountable-to.git
cd accountable-to
bundle install

# Set up access to secrets
export RAILS_MASTER_KEY=your_key_here

# Database setup
bin/rails db:setup

# Start the development server
bin/dev
```

Visit [http://localhost:3000](http://localhost:3000) to see the application in action!

### 🧪 **Running Tests**

```bash
# Run tests
bin/rails test

# Run system tests
bin/rails test:system    # System tests

# Code quality checks
bin/standardrb          # Ruby linting
bin/brakeman            # Security analysis
```

---

## 🚀 **Production Deployment**

### Kamal Deployment
Deploy to production with a single command using [Kamal](config/deploy.yml):

```bash
# Deploy to production
kamal deploy

# Check logs
kamal logs
```

**Configuration**: [config/deploy.yml](config/deploy.yml)

### Infrastructure as Code
VPS provisioning on Vultr using [Terraform](config/provision/):

```bash
cd config/provision/

# Configure your SSH key in server.yml
vi server.yml

# Generate Fedora CoreOS ignition file
docker run -it --rm -v $PWD/:/bld -v ~/.ssh:/bld/tmp/ssh \
  quay.io/coreos/butane:release --pretty --strict \
  /bld/server.yml --files-dir /bld > server.ign

# Provision infrastructure
terraform init
terraform apply
```

**Files**:
- **[main.tf](config/provision/main.tf)** - Infrastructure definition
- **[server.yml](config/provision/server.yml)** - CoreOS configuration
- **[variables.tf](config/provision/variables.tf)** - Terraform variables

---

## 🏗️ **Technical Highlights**

### Data Models
- **[User Model](app/models/user.rb)** - Authentication with magic links and email confirmation
- **[Goal Model](app/models/goal.rb)** - Goal management with AI integration
- **[Goal Messages](app/models/goal_message.rb)** - Conversation tracking

### Background Jobs
- **[Goal Title Generation](app/jobs/generate_goal_title_job.rb)** - AI-powered title creation
- **[Assistant Responses](app/jobs/generate_assistant_response_job.rb)** - Intelligent reply generation
- **[Check-in Processing](app/jobs/process_goal_check_in_job.rb)** - User interaction handling

### Email System
- **[Action Mailbox](app/mailboxes/)** - Inbound email processing
- **[Goal Mailer](app/mailers/goal_mailer.rb)** - Automated check-in emails
- **[User Mailer](app/mailers/user_mailer.rb)** - Authentication emails

---

## 📝 **License**

This project is available as open source under the terms of the [MIT License](LICENSE).

---

❤️ *Built to showcase a good understanding of all aspects of modern web application development* ❤️
