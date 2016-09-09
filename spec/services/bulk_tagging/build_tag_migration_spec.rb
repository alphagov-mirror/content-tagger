require 'rails_helper'

RSpec.describe BulkTagging::BuildTagMigration do
  let(:tag_migration_params) do
    {
      collection_content_id: 'content-id',
      collection_base_path: '/content-base-path',
      query: 'A query string'
    }
  end

  context 'without any taxons' do
    let(:tag_migration) do
      described_class.perform(
        tag_migration_params: tag_migration_params,
        taxon_content_ids: [],
        content_base_paths: ['/content-1']
      )
    end

    it 'raises an error' do
      expect { tag_migration }.to raise_error(
        BulkTagging::BuildTagMigration::InvalidArgumentError,
        /no taxons selected/i
      )
    end
  end

  context 'without any content items' do
    let(:tag_migration) do
      described_class.perform(
        tag_migration_params: tag_migration_params,
        taxon_content_ids: ['taxon-1'],
        content_base_paths: []
      )
    end

    it 'raises an error' do
      expect { tag_migration }.to raise_error(
        BulkTagging::BuildTagMigration::InvalidArgumentError,
        /no content items selected/i
      )
    end
  end

  context 'with 2 valid taxons and 2 content base paths' do
    before do
      linkables = [
        { "title" => "Taxon 1", "base_path" => "/foo", "content_id" => 'taxon-1' },
        { "title" => "Taxon 2", "base_path" => "/aha", "content_id" => 'taxon-2' },
      ]

      publishing_api_has_linkables(linkables, document_type: 'taxon')
    end

    let(:tag_migration) do
      described_class.perform(
        tag_migration_params: tag_migration_params,
        taxon_content_ids: ['taxon-1', 'taxon-2'],
        content_base_paths: ['/content-1', '/content-2']
      )
    end

    it 'builds an instance of a TagMigration' do
      expect(tag_migration).to be_a(TagMigration)
    end

    it 'builds a valid object' do
      expect(tag_migration).to be_valid
    end

    it 'assigns the original content id to the tag migration' do
      expect(tag_migration.original_link_content_id).to eq('content-id')
    end

    it 'assigns an initial state to the tag migration' do
      expect(tag_migration.state).to eq('ready_to_import')
    end

    it 'assigns the query to the tag migration' do
      expect(tag_migration.query).to eq('A query string')
    end

    it 'assigns the content base path to the tag migration' do
      expect(tag_migration.original_link_base_path).to eq('/content-base-path')
    end

    it 'it builds 4 tag mappings' do
      expect(tag_migration.tag_mappings.length).to eq(4)
    end

    it 'delegates the initialization of TagMapping records' do
      expect(BulkTagging::BuildTagMapping).to receive(:perform)
        .exactly(4)
        .times
        .and_return(TagMapping.new)

      tag_migration
    end
  end
end
