class UpdateTaxonWorker
  include Sidekiq::Worker
  BREXIT_TAXON_CONTENT_ID = "d6c2de5d-ef90-45d1-82d4-5f2438369eea".freeze

  def perform(content_id, attributes)
    previous_taxon = Taxonomy::BuildTaxon.call(content_id: content_id)
    updated_taxon = previous_taxon.clone
    updated_taxon.assign_attributes(attributes)

    Taxonomy::SaveTaxonVersion.call(updated_taxon, "Bulk update", previous_taxon: previous_taxon)

    Services.publishing_api.put_content(content_id, payload(updated_taxon))

    if content_id == BREXIT_TAXON_CONTENT_ID
      Services.publishing_api.put_content(content_id, payload(updated_taxon, "cy"))
    end
  end

private

  def payload(taxon, locale = "en")
    Taxonomy::BuildTaxonPayload.call(taxon: taxon, locale: locale)
  end
end
