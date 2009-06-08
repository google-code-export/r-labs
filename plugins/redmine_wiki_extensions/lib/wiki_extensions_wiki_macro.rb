# Wiki Extensions plugin for Redmine
# Copyright (C) 2009  Haruyuki Iida
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
require 'redmine'

module WikiExtensionsWikiMacro
  Redmine::WikiFormatting::Macros.register do
    desc "This is wiki macro"
    macro :wiki do |obj, args|
      return nil if args.length < 2
      project_name = args[0].strip
      page_name = args[1].strip
      project = Project.find_by_name(project_name)
      return nil unless project
      wiki = Wiki.find_by_project_id(project.id)
      return nil unless wiki
      page = wiki.find_page(page_name)
      return nil unless page

      o = ""
      o << link_to(page_name, :controller => 'wiki', :action => 'index', :id => project, :page => page_name)
      return o
    end
  end
end
