require 'test_helper'

class ArtefactRetrieverTest < ActiveSupport::TestCase
  class DummyStatsd
    def increment(*args); end
  end

  setup do
    @content_api = stub
    @retriever = ArtefactRetriever.new(@content_api, Rails.logger, DummyStatsd.new)
  end

  should "be able to fetch an artefact" do
    json_data = File.read(Rails.root.join('test/fixtures/register-to-vote.json'))
    artefact = GdsApi::Response.new(
      stub("HTTP_Response", code: 200, body: json_data),
      web_urls_relative_to: "https://www.gov.uk"
    )
    @content_api.expects(:artefact!).with('register-to-vote', {}).returns(artefact)
    assert_nothing_raised do
      @retriever.fetch_artefact('register-to-vote')
    end
  end

  should "raise a RecordNotFound if no artefact is returned" do
    @content_api.expects(:artefact!).with('beekeeping', {}).raises(GdsApi::HTTPNotFound.new(404))
    assert_raises ArtefactRetriever::RecordNotFound do
      @retriever.fetch_artefact('beekeeping')
    end
  end

  context "handling http errors" do
    should "raise a RecordArchived if a 410 status is returned" do
      @content_api.expects(:artefact!).with('fooey', {}).raises(GdsApi::HTTPGone.new(410))
      assert_raises ArtefactRetriever::RecordArchived do
        @retriever.fetch_artefact('fooey')
      end
    end

    should "re-raise a GdsApi::HttpErrorResponse on 5xx error" do
      @content_api.expects(:artefact!).with('fooey', {}).raises(GdsApi::HTTPErrorResponse.new(503))
      e = nil
      assert_raises GdsApi::HTTPErrorResponse do
        begin
          @retriever.fetch_artefact('fooey')
        rescue => ex
          e = ex
          raise
        end
      end

      assert_equal 503, e.code
    end

    should "handle non-HTTP level errors" do
      # e.g. tcp level errors that won't have a HTTP status code
      @content_api.expects(:artefact!).with('fooey', {}).raises(GdsApi::HTTPErrorResponse.new(nil))
      assert_raises GdsApi::HTTPErrorResponse do
        @retriever.fetch_artefact('fooey')
      end
    end
  end
end
