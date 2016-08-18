require 'rails_helper'

RSpec.describe TagImporter::LinksPublisher do
  describe '#publish' do
    context 'with valid link updates' do
      let(:links_update) do
        instance_double(LinksUpdate,
                        valid?: true,
                        content_id: 'a-content-id',
                        links_to_update: ['taxon1-content-id'])
      end

      it 'updates the links via the publishing API and marks the taggings as tagged' do
        expect(Services.publishing_api).to receive(:patch_links).with(
          links_update.content_id,
          links: links_update.links_to_update
        )
        expect(links_update).to receive(:mark_as_tagged)

        described_class.new(links_update: links_update).publish
      end
    end

    context 'with invalid link updates' do
      let(:links_update) { instance_double(LinksUpdate, valid?: false) }

      it 'does not call the publishing API and marks the taggings as errored' do
        expect(Services.publishing_api).to_not receive(:patch_links)
        expect(links_update).to receive(:mark_as_errored)

        described_class.new(links_update: links_update).publish
      end
    end
  end
end