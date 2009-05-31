require 'redmine'
require 'wiki_extensions_application_hooks'

Redmine::Plugin.register :redmine_wiki_extensions do
  name 'Redmine Wiki Extensions plugin'
  author 'Haruyuki Iida'
  description 'This is a plugin for Redmine'
  version '0.0.1'

  Redmine::WikiFormatting::Macros.register do
    desc "This is my macro"
    macro :my_macro do |obj, args|
      o = "My macro output"
      args.each{ |arg|  o << arg}
      o << ','
      o << obj.page.title
      o
    end
  end
end
