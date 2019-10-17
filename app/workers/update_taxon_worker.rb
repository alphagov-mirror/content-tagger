class UpdateTaxonWorker
  include Sidekiq::Worker
  include BrexitTaxon

  def perform(content_id, attributes)
    previous_taxon = Taxonomy::BuildTaxon.call(content_id: content_id)
    updated_taxon = previous_taxon.clone
    updated_taxon.assign_attributes(attributes)

    Taxonomy::SaveTaxonVersion.call(updated_taxon, "Bulk update", previous_taxon: previous_taxon)

    Services.publishing_api.put_content(content_id, payload(updated_taxon))
    return unless brexit_taxon?(content_id)

    Services.publishing_api.put_content(content_id, payload(updated_taxon, "cy"))
  end

private

  def payload(taxon, locale = "en")
    Taxonomy::BuildTaxonPayload.call(taxon: taxon, locale: locale)
  end
end
