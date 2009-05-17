# $Id$
# To change this template, choose Tools | Templates
# and open the template in the editor.

require "rexml/document"
require 'open-uri'
require 'hudson_exceptions'

RAILS_DEFAULT_LOGGER.info 'Starting Hudson plugin for RedMine'

class HudsonController < ApplicationController
  unloadable
  layout 'base'

  before_filter :find_project
  before_filter :find_settings
  before_filter :authorize

  include HudsonHelper
  include RexmlHelper

  def index
    @jobs = []

    raise HudsonNoSettingsException if @settings.is_new?

    # job/build, view, primaryView は省く
    api_url = "#{@settings.url}/api/xml?depth=1" + 
              "&xpath=/hudson" +
              "&exclude=/hudson/view" +
              "&exclude=/hudson/primaryView" +
              "&exclude=/hudson/job/build" +
              "&exclude=/hudson/job/lastBuild" +
              "&exclude=/hudson/job/lastCompletedBuild" +
              "&exclude=/hudson/job/lastStableBuild" +
              "&exclude=/hudson/job/lastSuccessfulBuild"
    content = open(api_url)
    doc = REXML::Document.new content
    doc.elements.each("hudson/job") do |element|
      @jobs << make_job(element) if is_target?(get_element_value(element, "name"))
    end

  rescue HudsonNoSettingsException
    flash.now[:error] = l(:notice_err_no_settings, url_for(:controller => 'hudson_settings', :action => 'edit', :id => @project))
  rescue OpenURI::HTTPError => error
    flash.now[:error] = l(:notice_err_http_error, error.message)
  rescue Errno::ECONNREFUSED, Errno::ETIMEDOUT 
    flash.now[:error] = l(:notice_err_cant_connect)
  end

  def build
    raise HudsonNoSettingsException if @settings.is_new?
    raise HudsonNoJobException if params[:name] == nil

    build_url = "#{@settings.url}/job/#{params[:name]}/build"

    content = ""
    open(build_url) do |s| content = s.read end
    p "info --> #{content}"

  rescue HudsonNoSettingException
    render :text => "#{l(:notice_err_build_failed, :notice_err_no_settings)}"
  rescue HudsonNoJobException
    render :text => "#{l(:notice_err_build_failed_no_job, params[:name])}"
  else
    render :text => "#{params[:name]} #{l(:build_accepted)}"
  end

private
  def find_project
    @project = Project.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def find_settings
    @settings = HudsonSettings.load(@project)
  end

  def is_target?(job)
    return @settings.job_include?(job)
  end

  def make_job( element )
    retval = {}
    retval[:name] = get_element_value(element, "name")
    retval[:description] = get_element_value(element, "description")
    retval[:url] = get_element_value(element, "url")
    retval[:state] = get_element_value(element, "color")

    retval[:healthReport] = []
    element.elements.each("healthReport") do |hReport|
      report = {}
      report[:description] = get_element_value(hReport, "description")
      report[:score] = get_element_value(hReport, "score")
      retval[:healthReport] << report
    end

    retval[:latestBuild] = make_latest_build( retval[:name] )

    return retval
  end

  def make_latest_build( name )

    retval = {}
    retval[:number] = ""
    retval[:result] = ""
    retval[:url] = ""
    retval[:timestamp] = ""

    api_url = "#{@settings.url}/job/#{name}/lastBuild/api/xml?"

    begin
      # Open the feed and parse it
      content = open(api_url)
      doc = REXML::Document.new content
    rescue OpenURI::HTTPError => error
      # TODO:ここどうしよう？
      return retval
    rescue Errno::ECONNREFUSED, Errno::ETIMEDOUT 
      # TODO:ここどうしよう？
      return retval
    end

    if doc.root != nil
      retval[:number] = get_element_value(doc.root, "number")
      retval[:result] = get_element_value(doc.root, "result")
      retval[:url] = get_element_value(doc.root, "url")
      retval[:timestamp] = Time.at( get_element_value(doc.root, "timestamp").to_f / 1000 )
    end

    return retval

  end

end
