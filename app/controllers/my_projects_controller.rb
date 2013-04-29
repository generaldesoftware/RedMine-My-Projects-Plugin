# My projects - plugin for Redmine
# Copyright (C) 2011 - 2012  Gonzalo Garcia Jaubert
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

# Generate the project lists to show.
class MyProjectsController < ApplicationController
  unloadable
  
  helper :my_projects
  
  # Get all projects you are member of.
  def index

	@showProjects = []
	show_projects_closed = 0
	unless params[:closed]
          show_projects_closed = 1
        end

	if (show_projects_closed == 1)
		@allProjects = Project.visible(User.current).find(:all, :order => 'lft', :conditions => ["#{Project.table_name}.status=#{Project::STATUS_ACTIVE}"])
	else
		@allProjects = Project.visible(User.current).find(:all, :order => 'lft')
	end	
	id = params[:id]

	if !(id)
		projectsList = @allProjects - getProjectsNoMember()
		@showProjects = getRootProjects(projectsList)
	else
		parentProject = Project.find_by_id(id)
		childProjects = getChildProject(parentProject)
		@showProjects = getRootProjectsFromList(childProjects)
	end
	@allProjects = @allProjects - getProjectsNoMember()
	return @showProjects
  end
  
private

	# Return a list of root projects
	def getRootProjects(projectsLists)
		rootProjects = projectsLists - getChildProjects(projectsLists)
	end
	
	#Return a list of root projects from a Lists of projects (def initialize(*args)?)
	def getRootProjectsFromList(parentProject)
		rootProjects = parentProject - getChildProjects(parentProject)
	end
	
	# Return a list of child projects
	def getChildProjects(projectsLists)
		indice = 0
		childProjects = []
		while (indice < projectsLists.size)
			projectsLists.each do |project|
				if (isChildproject(project, projectsLists[indice]))
					childProjects = childProjects << project
				end
			end
			indice += 1
		end
		return childProjects
	end
	
	# Return all childs project from parentProject
	def getChildProject(parentProject)
		childProjects = []
		@allProjects.each do |project|
			if (project.is_descendant_of?(parentProject))
				if (User.current.member_of?(project))
					childProjects = childProjects << project
				end
			end
		end		
		return childProjects
	end
	
	# true if childproject is child of parentproject
	def isChildproject(childproject, parentproject)
		isChild = false
		if (childproject.id != parentproject.id)
			if (childproject.is_descendant_of?(parentproject))
				isChild = true
			end
		end	
		return isChild
	end
	
	# Return a list of projects where the user is not member of
	def getProjectsNoMember()
		noMemberProjects = []
		@allProjects.each do |project|
			if !(User.current.member_of?(project))
				noMemberProjects = noMemberProjects << project
			end	
		end
		return noMemberProjects
	end	
	
end
