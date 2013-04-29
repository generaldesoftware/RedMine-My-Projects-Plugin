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

module MyProjectsHelper

	# Render the My Projects box
	def render_project_hierarchy(filterProjects, allProjects)
		s = ''
		
		filterProjects.each do |currentProject|
			s << "<div class='mosaic-block bar2'>"
				s << "<div class='mosaic-overlay'>"						
					s = s << htmlProject(currentProject) # Get the a href to project
					s = s << linkToSubProjects(currentProject, allProjects) # Get the subprojects of current project
					s = s << linkToBackDetail(currentProject, allProjects) # Get the link to parent project
				s << "</div>"
				imgUrl = linkToImage(currentProject)
				s << "<div class='mosaic-backdrop'><img src='#{imgUrl}'/></div>"			
			s << "</div>"	
		end
		return s.html_safe
	end
	
	def render_title(filterProjects, allProjects)
		s= ''
		
		s = s << "<h2>#{l(:application_name)}</h2>"
		currentProject = filterProjects[0]
		s = s << linkToBackTitle(currentProject, allProjects) # Get the link to parent project
		
		return s.html_safe
	end
  
private

	# link to currentProject
	def htmlProject(currentProject)
		s = ''
		imgLink = url_for (:action => 'show', :controller => 'projects', :id => currentProject.identifier, :only_path => true)
		s << "<a href='#{imgLink}' >"						
			s << "<div class='detailsmyprojects'>"
				s << "<h4>#{currentProject.name}</h4>"
				s << "#{textilizable(currentProject.short_description, :project => currentProject)}"
			s << "</div>"
		s << "</a>"				
		return s
	end

	# link to subprojects. Show the number of subprojects
	def linkToSubProjects(currentProject, allProjects)
		s = ''
		subProjectsNumber = getSubProjectsCount(currentProject, allProjects)
		if (subProjectsNumber > 0)
			subprojectsLink = url_for (:controller => 'my_projects', :action => 'index', :id => currentProject.id)					
			s << "<a href='#{subprojectsLink}'>"
			s << "<div class='detailsmyprojects'><p>#{l(:subprojects_see)} (#{subProjectsNumber})</p></div>"
			s << "</a>"
		end
		return s
	end
	
	# link to parent	
	def linkToBack(currentProject, allProjects)
		#s = ''
		parentProjectLink = ''
		parentProject = getFirstParent(currentProject, allProjects)
		if (parentProject != nil)
			parentParentProject = getFirstParent(parentProject, allProjects)
			if (parentParentProject != nil)
				parentProjectLink = url_for (:controller => 'my_projects', :action => 'index', :id => parentParentProject.id)					
			else
				parentProjectLink = url_for (:controller => 'my_projects', :action => 'index', :id => nil)					
			end
		end
		return parentProjectLink
	end
	
	def linkToBackTitle(currentProject, allProjects)
		s = ''
		parentProjectLink = linkToBack(currentProject, allProjects) # Get the link to parent project
		if (parentProjectLink != '')
			s = "<div class=''><a href='#{parentProjectLink}'>#{l(:back)}</a></div>"
		end
		
		return s	
	end
	
	def linkToBackDetail(currentProject, allProjects)
		s = ''
		parentProjectLink = linkToBack(currentProject, allProjects) # Get the link to parent project
		if (parentProjectLink != '')
			s = "<a href='#{parentProjectLink}'>"
			s << "<div class='detailsmyprojects'><p>#{l(:back)}</p></div>"
			s << "</a>"					
		end
		return s
	end

	# link to logo.png
	def linkToImage(currentProject)
		projectWithAttachments = Project.find(currentProject.id, :include => :attachments)
		result = MyPluginAssetHelpers.plugin_asset_link ("images/logo.png",:plugin =>'redmine_gsc_my_projects')
        	projectWithAttachments.attachments.each do |file|
			if (file.filename == "logo.png")
				result = url_for (:controller => 'attachments', :action => 'download', :id => file.id)
			end
		end
		return result
	end
	
	# get the total number of subprojects
	def getSubProjectsCount(currentProject, allProjects)
		number = 0
		allProjects.each do |project|
			if (project.is_descendant_of?(currentProject))
				if (User.current.member_of?(project))
					number = number + 1
				end
			end
		end		
		return number
	end	
	
	# get the first parent of currentProject
	def getFirstParent(currentProject, allProjects)
		parent = nil
		allProjects.each do |project|
			if (currentProject.id != project.id)
				if (currentProject.is_descendant_of?(project))
					parent = project		# The last parent is the first parent
				end
			end
		end		
		return parent
	end
end

