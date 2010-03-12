require 'rubygems'
require 'rake'
require 'rake/clean'
require 'rake/gempackagetask'
require 'rake/rdoctask'
require 'spec/rake/spectask'

spec = Gem::Specification.new do |s|
  s.name = 'action_annotation'
  s.version = '1.0.1'
  s.has_rdoc = true
  s.extra_rdoc_files = ['README', 'MIT-LICENSE', 'CHANGELOG']
  s.summary = 'Add descriptions to methods'
  s.description = 
    'This gem introduces means for describing the content of methods in a ' +
    'human readable way. The descriptions are parsed and provided as hashes ' +
    'at runtime. This feature is intended to be used for controller ' +
    'actions to automatize parts of your rails application, but it ' +
    'can be included in other classes as well.'
  s.author = 'Nico Rehwaldt, Arian Treffer'
  s.email = 'ruby@nixis.de'
  s.homepage = 'http://tech.lefedt.de/2010/3/annotation-based-security-for-rails'
  s.files = %w(CHANGELOG MIT-LICENSE README Rakefile) + Dir.glob("{bin,lib,spec}/**/*")
  s.require_path = "lib"
  s.bindir = "bin"
end

Rake::GemPackageTask.new(spec) do |p|
  p.gem_spec = spec
  p.need_tar = true
  p.need_zip = true
end

Rake::RDocTask.new do |rdoc|
  files = ['README', 'MIT-LICENSE', 'CHANGELOG', 'lib/**/*.rb']
  rdoc.rdoc_files.add(files)
  rdoc.main = "README" # page to start on
  rdoc.title = "Action Annotation Docs"
  rdoc.rdoc_dir = 'doc' # rdoc output folder
  rdoc.options << '--line-numbers'
end

Spec::Rake::SpecTask.new do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
end