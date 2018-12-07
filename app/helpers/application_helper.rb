# Helpers are used to generalize the app, but this one makes use of some external helpers
require 'bbb_lti_broker/helpers'

# Helpers for the application
module ApplicationHelper
  include BbbLtiBroker::Helpers

  CAP_TO_DESCRIPTIONS = {
    'accountNavigation' => 'Account Navigation',
    'courseNavigation' => 'Course Navigation',
    'assignmentSelection' => 'Assignment Selection',
    'linkSelection' => 'Link Selection'
  }

  def display_cap(cap)
    if CAP_TO_DESCRIPTIONS.keys.include? cap
      CAP_TO_DESCRIPTIONS[cap]
    else
      cap
    end
  end

  def log_div(seed, n)
    div = seed
    n.times do
      div += seed
    end
    div
  end

  def log_hash(h)
    logger.info log_div('*', 100)
    h.sort.map do |key, value|
      logger.info "#{key}: " + value
    end
    logger.info log_div('*', 100)
  end

  class CustomError < StandardError;
    attr_reader :error
    def initialize(error = :unknown)
      @error = error
    end
  end

  def lti_authorized_application
    raise CustomError.new(:missing_app) unless params.key?(:app)
    raise CustomError.new(:not_found) unless params[:app] == 'default' || authorized_tools.key?(params[:app])
  end

  def lti_secret(key)
    tool = RailsLti2Provider::Tool.find_by_uuid(key)
    return tool.shared_secret if tool
  end

  def authorized_tools
    Doorkeeper::Application.all.select("id, name, uid, secret, redirect_uri").to_a.map { |app| [app.name, app.attributes] }.to_h
  end
end