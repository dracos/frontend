class TravelAdviceController < ApplicationController
  FOREIGN_TRAVEL_ADVICE_SLUG = 'foreign-travel-advice'.freeze

  def index
    set_expiry
    setup_content_item_and_navigation_helpers("/" + FOREIGN_TRAVEL_ADVICE_SLUG)
    @presenter = TravelAdviceIndexPresenter.new(@content_item)

    respond_to do |format|
      format.html { render locals: { full_width: true } }
      format.atom { set_expiry(5.minutes) }
    end
  end
end
