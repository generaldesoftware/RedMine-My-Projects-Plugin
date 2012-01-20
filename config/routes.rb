# Default routes are no longer supported by Redmine
# Added default route

ActionController::Routing::Routes.draw do |map|
	map.connect 'my_projects/:action/:id', :controller => 'my_projects'
end