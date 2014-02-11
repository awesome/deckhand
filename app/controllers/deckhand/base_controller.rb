class Deckhand::BaseController < ApplicationController

  after_filter :set_csrf_cookie

  protected

  def set_csrf_cookie
    cookies['XSRF-TOKEN'] = form_authenticity_token
  end

  def verified_request?
    super || form_authenticity_token == request.headers['X-XSRF-TOKEN']
  end

  def model_config
    @model_config ||= Deckhand.config.for_model(params[:model])
  end
  helper_method :model_config

end