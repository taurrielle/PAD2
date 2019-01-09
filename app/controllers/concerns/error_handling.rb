require 'error/error.rb'
module ErrorHandling
  extend ActiveSupport::Concern

  included do
    rescue_from Error::CustomError, :with => :handle_api_exception
  end

  private

  def handle_api_exception(error)
    hash = error.hash_with_params(params)
    render json: hash.to_json, :status => error.status
  end
end
