require "test_helper"

class BusinessSupportControllerTest < ActionController::TestCase
  context "GET show" do
    setup do
      @artefact = artefact_for_slug('business-support-example')
      @artefact["format"] = "business_support"
    end

    context "for live content" do
      setup do
        content_api_and_content_store_have_page('business-support-example', @artefact)
      end

      should "set the cache expiry headers" do
        get :show, slug: "business-support-example"

        assert_equal "max-age=1800, public", response.headers["Cache-Control"]
      end

      should "redirect json requests to the api" do
        get :show, slug: "business-support-example", format: 'json'

        assert_redirected_to "/api/business-support-example.json"
      end
    end

    context "for draft content" do
      setup do
        content_api_and_content_store_have_unpublished_page("business-support-example", 3, @artefact)
      end

      should "does not set the cache expiry headers" do
        get :show, slug: "business-support-example", edition: 3

        assert_nil response.headers["Cache-Control"]
      end
    end
  end
end