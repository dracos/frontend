require "test_helper"

class AnswerControllerTest < ActionController::TestCase
  include EducationNavigationAbTestHelper

  context "GET show" do
    setup do
      content_store_has_random_item(base_path: "/molehills", schema: 'answer')
    end

    context "for live content" do
      should "set the cache expiry headers" do
        get :show, slug: "molehills"

        assert_equal "max-age=1800, public", response.headers["Cache-Control"]
      end
    end

    context "A/B testing" do
      setup do
        setup_education_navigation_ab_test
      end

      %w[A B].each do |variant|
        should "not affect non-education pages with the #{variant} variant" do
          setup_ab_variant('EducationNavigation', variant)
          expect_normal_navigation
          get :show, slug: "molehills"
          assert_response_not_modified_for_ab_test('EducationNavigation')
        end
      end

      should "show normal navigation by default" do
        expect_normal_navigation
        get :show, slug: "tagged-to-taxon"
      end

      should "show normal breadcrumbs for the 'A' version" do
        expect_normal_navigation
        with_variant EducationNavigation: "A" do
          get :show, slug: "tagged-to-taxon"
        end
      end

      should "show taxon breadcrumbs for the 'B' version" do
        expect_new_navigation
        with_variant EducationNavigation: "B" do
          get :show, slug: "tagged-to-taxon"
        end
      end
    end
  end
end
