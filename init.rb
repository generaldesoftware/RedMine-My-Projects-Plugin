require 'redmine'

Redmine::Plugin.register :redmine_gsc_my_projects do
  name 'Redmine GSC My Projects plugin'
  author 'Gonzalo Garcia Jaubert'
  description 'This is a plugin for Redmine. Show only projects you are member of (with a little of jquery).'
  version '0.0.1'
  url 'http://www.gsc.es'
  author_url 'http://www.gsc.es'

  menu :top_menu, :my_projects, { :controller => 'my_projects', :action => 'index', :id => nil }, :caption => :application_name
  
end
