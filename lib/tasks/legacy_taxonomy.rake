namespace :legacy_taxonomy do
  namespace :mainstream_browse do
    desc "Generates structure for mainstream browse at www.gov.uk/browse"
    task generate_taxons: :environment do
      taxonomy = LegacyTaxonomy::ThreeLevelTaxonomy.new('/foo').to_taxonomy_branch
      LegacyTaxonomy::Yamlizer.new('tmp/msbp.yml').write(taxonomy)
    end

    desc "Send the Mainstream Browse taxonomy to the publishing platform"
    task publish_taxons: :environment do
      taxonomy_branch = LegacyTaxonomy::Yamlizer.new('tmp/msbp.yml').read
      LegacyTaxonomy::TaxonomyPublisher.new(taxonomy_branch).commit
    end
  end

  namespace :topic do
    desc "Generates structure for Topic taxonomy at www.gov.uk/browse"
    task generate_taxons: :environment do
      taxonomy = LegacyTaxonomy::ThreeLevelTaxonomy.new('/qux',
                                                        base_path: '/topic',
                                                        first_level_key: 'children',
                                                        second_level_key: 'children',
                                                        title: 'Topic Taxonomy').to_taxonomy_branch
      LegacyTaxonomy::Yamlizer.new('tmp/topic.yml').write(taxonomy)
    end

    desc "Send the Topic taxonomy to the publishing platform"
    task publish_taxons: :environment do
      taxonomy_branch = LegacyTaxonomy::Yamlizer.new('tmp/topic.yml').read
      LegacyTaxonomy::TaxonomyPublisher.new(taxonomy_branch).commit
    end
  end

  namespace :policy_area do
    desc "Generates structure for Policy Areas at www.gov.uk/government/topics"
    task generate_taxons: :environment do
      taxonomy = LegacyTaxonomy::PolicyAreaTaxonomy.new('/bar').to_taxonomy_branch
      LegacyTaxonomy::Yamlizer.new('tmp/policy_area.yml').write(taxonomy)
    end
  end

  namespace :policy do
    desc "Generates structure for Policy Areas => Policy"
    task generate_taxons: :environment do
      taxonomy = LegacyTaxonomy::PolicyTaxonomy.new('/baz').to_taxonomy_branch
      File.write('tmp/policy.yml', YAML.dump(taxonomy))
    end
  end

  namespace :statistics do
    desc "Generate taxonomy statistics CSV"
    task generate: :environment do
      _ = LegacyTaxonomy::TaxonData
      %w(msbp policy_area policy).each do |tax|
        taxonomy = YAML.load_file("tmp/#{tax}.yml")
        taxons_array = LegacyTaxonomy::Statistics.new(taxonomy).to_a
        CSV.open("tmp/#{tax}.csv", "wb") do |csv|
          csv << taxons_array.first.keys
          taxons_array.each { |hash| csv << hash.values }
        end
      end
    end
  end
end
