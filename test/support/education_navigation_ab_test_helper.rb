module EducationNavigationAbTestHelper
  include GovukAbTesting::MinitestHelpers

  def setup_education_navigation_ab_test
    set_new_navigation
    content_api_and_content_store_have_page_tagged_to_taxon("a-slug")
  end

  def set_new_navigation
    ENV['ENABLE_NEW_NAVIGATION'] = 'yes'
  end

  def teardown_education_navigation_ab_test
    ENV['ENABLE_NEW_NAVIGATION'] = nil
  end

  def sidebar
    Nokogiri::HTML.parse(response.body).at_css(".related-container")
  end

  def expect_normal_navigation
    GovukNavigationHelpers::NavigationHelper.any_instance.expects(:breadcrumbs)
    GovukNavigationHelpers::NavigationHelper.any_instance.expects(:related_items)
  end

  def expect_new_navigation
    GovukNavigationHelpers::NavigationHelper.any_instance.expects(:taxon_breadcrumbs)
    GovukNavigationHelpers::NavigationHelper.any_instance.expects(:taxonomy_sidebar)
  end
end