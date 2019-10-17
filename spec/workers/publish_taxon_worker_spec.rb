require "rails_helper"

RSpec.describe PublishTaxonWorker, "#perform" do
  include PublishingApiHelper
  include ContentItemHelper

  it "makes a publish request to Publishing API for the Brexit taxon with 'cy' locale" do
    brexit_taxon_content_id = "d6c2de5d-ef90-45d1-82d4-5f2438369eea"
    stub_any_publishing_api_publish

    PublishTaxonWorker.new.perform(brexit_taxon_content_id)

    assert_publishing_api_publish(brexit_taxon_content_id, request_json_includes(locale: "cy"))
  end
end
