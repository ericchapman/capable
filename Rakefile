# encoding: UTF-8
require 'rubygems'
require 'bundler' unless defined?(Bundler)

$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
require 'capable/version'

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.test_files = Dir.glob("test/**/*_test.rb")
  test.verbose = true
end

require 'rake'
require 'rspec/core/rake_task'
 
RSpec::Core::RakeTask.new(:spec) do |test|
  test.pattern = Dir.glob('spec/**/*_spec.rb')
  test.rspec_opts = '--format documentation'
  # test.rspec_opts << ' more options'
  # test.rcov = true
end
task :default => :spec

task :build do
  system "gem build capable.gemspec"
end

task :release => :build do
  system "gem push capable-#{Capable::VERSION}.gem"
  system "rm capable-#{Capable::VERSION}.gem"
end

task :test_all_databases do
  # Test MySQL, Postgres and SQLite3
  # ENV['DB'] = 'mysql'
  # Rake::Task['spec'].execute
  # ENV['DB'] = 'postgres'
  # Rake::Task['spec'].execute
  ENV['DB'] = 'sqlite3'
  Rake::Task['spec'].execute
end

task :default => :test_all_databases

