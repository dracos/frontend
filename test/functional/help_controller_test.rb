require "test_helper"

class HelpControllerTest < ActionController::TestCase
  context "GET index" do
    setup do
      content_store_has_random_item(base_path: "/help")
    end

    should "set the cache expiry headers" do
      get :index

      assert_equal "max-age=1800, public", response.headers["Cache-Control"]
    end

    should "redirect json requests to the api" do
      get :index, format: 'json'

      assert_redirected_to "/api/help.json"
    end
  end

  context "GET show" do
    setup do
      @artefact = artefact_for_slug('help/cookies')
      @artefact["format"] = "help"
    end

    context "for live content" do
      setup do
        content_api_and_content_store_have_page('help/cookies', @artefact)
      end

      should "set the cache expiry headers" do
        get :show, slug: "help/cookies"

        assert_equal "max-age=1800, public", response.headers["Cache-Control"]
      end

      should "redirect json requests to the api" do
        get :show, slug: "help/cookies", format: 'json'

        assert_redirected_to "/api/help/cookies.json"
      end
    end

    context "for draft content" do
      setup do
        content_api_and_content_store_have_unpublished_page("help/cookies", 3, @artefact)
      end

      should "does not set the cache expiry headers" do
        get :show, slug: "help/cookies", edition: 3

        assert_nil response.headers["Cache-Control"]
      end
    end
  end

  context "loading the tour page" do
    setup do
      content_store_has_random_item(base_path: "/tour")
    end

    should "respond with success" do
      get :tour

      assert_response :success
    end

    should "set correct expiry headers" do
      get :tour

      assert_equal "max-age=1800, public", response.headers["Cache-Control"]
    end
  end

  context "GET ab-testing" do
    include GovukExperiment::MinitestHelpers

    should "respond with success" do
      get :ab_testing, slug: "help/ab-testing"

      assert_response :success
    end

    should "show the user the 'A' version if the user is in bucket 'A'" do
      with_variant example: "A" do
        get :ab_testing

        assert_select ".ab-example-group", text: "A"
        assert_ab_test_rendered('example')
      end
    end

    should "show the user the 'B' version if the user is in bucket 'A'" do
      with_variant example: "B" do
        get :ab_testing

        assert_select ".ab-example-group", text: "B"
        assert_ab_test_rendered('example')
      end
    end

    should "show the user the default version if the user is not in a bucket" do
      get :ab_testing

      assert_select ".ab-example-group", text: "A"
      assert_ab_test_rendered('example')
    end

    should "show the user the default version if the user is in an unknown bucket" do
      with_variant example: "not_a_valid_AB_test_value" do
        get :ab_testing

        assert_select ".ab-example-group", text: "A"
        assert_ab_test_rendered('example')
      end
    end
  end
end
