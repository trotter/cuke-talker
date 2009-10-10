#!/usr/bin/env ruby
require 'rubygems'
require 'cucumber'

class CukeTalker
  def self.start_repl(features_dir)
    new(features_dir).run_repl
  end

  def initialize(features_dir)
    @features_dir = features_dir
    @step_mother = Cucumber::StepMother.new
    @out = StringIO.new
    @err = StringIO.new
    configuration = Cucumber::Cli::Configuration.new(@out, @err)
    configuration.parse!([])
    @step_mother.options = configuration.options
    @step_mother.load_code_files(Dir["#{@features_dir}/support/*.rb"])
    @step_mother.load_code_files(Dir["#{@features_dir}/step_definitions/*.rb"])
    @visitor = configuration.build_formatter_broadcaster(@step_mother)
    @step_mother.visitor = @visitor
    @steps = []
    @step_definitions = []
  end

  def run_repl
    print ">> "
    while !@stop && (line = gets)
      begin
        run line.chomp
      rescue => e
        puts "You had an error: #{e}"
      end
      print ">> "
    end
    puts
  end

  def run(command)
    process_command(command)
    process_output
  end

  def process_command(command)
    send("process_#{command_type(command)}", command)
  end

  def process_step(step)
    @steps << step
    path = "/tmp/cucumber_repl.feature"
    file = File.open(path, "w") do |f|
      f.puts "  Scenario: Another step"
      f.puts "    #{step}"
    end
    features = @step_mother.load_plain_text_features([path])
    @visitor.visit_features(features)
    File.delete(path)
  end

  def process_ruby(ruby)
    eval ruby[1..-1]
  end

  def process_define_step(_)
    stop = false
    step_definition = ""
    print "$$ "
    while !stop && (line = gets)
      if line.chomp =~ /^ *done *$/i
        stop = true
      else
        step_definition << line
        print "$$ "
      end
    end
    add_step_definition(step_definition)
    puts
  end

  def add_step_definition(definition)
    @step_definitions << definition
    path = "/tmp/new_cucumber_step.rb"
    file = File.open(path, "w") do |f|
      f.puts definition
    end
    @step_mother.load_code_files([path])
    File.delete(path)
  end

  def process_other(command)
    case command
    when /^ *exit *$/
      @stop = true
    when /show history/
      puts @steps.join("\n")
    when /show step definitions/
      puts @step_definitions.join("\n")
    else
      puts "Cannot do anything with '#{command}'"
    end
  end

  def command_type(command)
    case command
    when /^(Given|When|Then|And)/
      :step
    when /^!/
      :ruby
    when /define step/
      :define_step
    else
      :other
    end
  end

  def process_output
    @out.rewind
    @err.rewind
    puts @out.read
    puts @err.read
    @out.truncate(0)
    @err.truncate(0)
  end
end

if $0 == __FILE__
  features_folder = ARGV.shift || "features"
  CukeTalker.start_repl features_folder
end

