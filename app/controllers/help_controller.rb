class HelpController < ApplicationController
  include ApiRedirectable
  include Previewable
  include Cacheable

  before_filter -> { setup_content_item_and_navigation_helpers("/" + params[:slug]) }, only: :show
  before_filter :set_publication, only: :show

  def index
    setup_content_item_and_navigation_helpers("/help")
  end

  def tour
    setup_content_item_and_navigation_helpers("/tour")
    render locals: { full_width: true }
  end

  def show
  end

  def ab_testing
    @experiment = GovukExperiment::Experiment.new("example", request)
  end

private

  def slug_param
    params[:slug] || 'help'
  end
end
