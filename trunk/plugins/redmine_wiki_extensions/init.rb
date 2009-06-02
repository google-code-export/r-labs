require 'redmine'
require 'wiki_extensions_application_hooks'
require 'wiki_extensions_wiki_page_patch'
require 'wiki_extensions_footnote'

Redmine::Plugin.register :redmine_wiki_extensions do
  name 'Redmine Wiki Extensions plugin'
  author 'Haruyuki Iida'
  description 'This is a plugin for Redmine'
  version '0.0.1'

  
end

