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

module WikiExtensionsFootnote
  Redmine::WikiFormatting::Macros.register do
    desc "This is Footnote macro"
    macro :fn do |obj, args|
      return nil if args.length < 2
      word = args[0]
      description = args[1]
      page = obj.page
      data = page.wiki_extension_data
      data[:footnotes] ||= []
      data[:footnotes] << {'word' => word, 'description' => description}

      o = ""
      o << word
      o << '<a href="#wiki_extensins_fn_' +"#{data[:footnotes].length}" + '" class="wiki_extensions_fn" title="' + description + '" name="wiki_extensins_fn_src_' +"#{data[:footnotes].length}" + '">'
      o << "[#{data[:footnotes].length}]"
      o << '</a>'
      return o
    end
  end

  Redmine::WikiFormatting::Macros.register do
    desc "This is Footnote list macro"
    macro :fnlist do |obj, args|
      page = obj.page
      data = page.wiki_extension_data
      return '' if data[:footnotes].blank? or data[:footnotes].empty?
      o = '<div class="wiki_extensions_fnlist">'
      o << '<ul>'
      cnt = 0
      data[:footnotes].each {|fn|
        cnt += 1
        o << '<li>'+ "[#{cnt}] " +'<a name="wiki_extensins_fn_' + "#{cnt}" + '" href="#wiki_extensins_fn_src_' + "#{cnt}" + '"' + ">#{fn['word']}</a>:#{fn['description']}</li>"
      }
      o << '</ul>'
      o << '</div>'
      return o
    end
  end
end
