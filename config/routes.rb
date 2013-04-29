# Default routes are no longer supported by Redmine
# Added default routel
get 'my_projects', :to => 'my_projects#index'
post 'my_projects/:id/:action', :to => 'my_projects'


