require "slimmer/headers"

class PlaceController < ApplicationController
  before_filter :redirect_if_api_request
  before_filter -> { set_expiry unless viewing_draft_content? }

  helper_method :postcode_provided?, :postcode

  INVALID_POSTCODE_ERROR = "invalidPostcodeError".freeze
  NO_LOCATION_ERROR = "validPostcodeNoLocation".freeze

  REPORT_CHILD_ABUSE_SLUG = "report-child-abuse-to-local-council".freeze

  def show
    setup_content_item_and_navigation_helpers("/" + params[:slug])
    @edition = params[:edition]
    @publication = publication

    render :show, locals: locals
  end

private

  def publication
    if postcode_provided?
      PublicationPresenter.new(artefact, places)
    else
      PublicationPresenter.new(artefact)
    end
  end

  def artefact
    @_artefact ||= ArtefactRetrieverFactory.artefact_retriever.fetch_artefact(
      params[:slug],
      params[:edition]
    )
  end

  def locals
    if params[:slug] == REPORT_CHILD_ABUSE_SLUG
      {
        option_partial: "option_report_child_abuse",
        preposition: "for"
      }
    else
      {}
    end
  end

  def postcode_provided?
    params[:postcode].present?
  end

  def postcode
    PostcodeSanitizer.sanitize(params[:postcode])
  end

  def redirect_if_api_request
    redirect_to "/api/#{params[:slug]}.json" if request.format.json?
  end

  def viewing_draft_content?
    params.include?('edition')
  end

  def places
    places = Frontend.imminence_api.places_for_postcode(artefact["details"]["place_type"], postcode, Frontend::IMMINENCE_QUERY_LIMIT)
    @location_error = LocationError.new(NO_LOCATION_ERROR) if places.blank?
    places
  rescue GdsApi::HTTPErrorResponse => e
    if imminence_error_for_invalid_postcode?(e)
      @location_error = LocationError.new(INVALID_POSTCODE_ERROR)
    elsif imminence_error_for_no_mapit_location?(e)
      @location_error = LocationError.new(NO_LOCATION_ERROR)
    else
      raise
    end
  end

  def imminence_error_for_invalid_postcode?(error)
    error.error_details.fetch("error") == INVALID_POSTCODE_ERROR
  end

  def imminence_error_for_no_mapit_location?(error)
    error.error_details.fetch("error") == NO_LOCATION_ERROR
  end
end