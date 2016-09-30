require "rails_helper"

RSpec.describe Linkables do
  let(:linkables) { Linkables.new }

  describe ".topics" do
    it 'returns an array of hashes with title and content id pairs' do
      publishing_api_has_linkables(
        [
          {
            "public_updated_at" => "2016-04-07 10:34:05",
            "title" => "Pension scheme administration",
            "content_id" => "e1d6b771-a692-4812-a4e7-7562214286ef",
            "publication_state" => "live",
            "base_path" => "/topic/business-tax/pension-scheme-administration",
            "internal_name" => "Business tax / Pension scheme administration"
          }
        ],
        document_type: "topic",
      )

      expected = {
        "Business tax" => [
          ["Business tax / Pension scheme administration", "e1d6b771-a692-4812-a4e7-7562214286ef"]
        ]
      }

      expect(linkables.topics).to eq expected
    end
  end

  describe ".organisations" do
    it "returns an array of arrays with title and content id pairs" do
      publishing_api_has_linkables(
        [
          {
            "public_updated_at" => "2014-10-15 14:35:22",
            "title" => "Student Loans Company",
            "content_id" => "9a9111aa-1db8-4025-8dd2-e08ec3175e72",
            "publication_state" => "live",
            "base_path" => "/government/organisations/student-loans-company",
            "internal_name" => "Student Loans Company"
          },
        ],
        document_type: "organisation",
      )

      expect(linkables.organisations).to eq [["Student Loans Company", "9a9111aa-1db8-4025-8dd2-e08ec3175e72"]]
    end
  end
end
