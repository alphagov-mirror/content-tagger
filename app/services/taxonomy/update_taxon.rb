module Taxonomy
  class UpdateTaxon
    attr_reader :taxon
    delegate :content_id, :parent, :associated_taxons, to: :taxon

    class InvalidTaxonError < StandardError; end

    def initialize(taxon:)
      @taxon = taxon
    end

    def self.call(taxon:, validate: true)
      new(taxon: taxon).publish(validate: validate)
    end

    def publish(validate: true)
      if validate && !taxon.valid?
        raise "Invalid Taxon passed into UpdateTaxon: #{taxon.errors.full_messages}"
      end

      Services.publishing_api.put_content(content_id, payload)
      ::Taxonomy::ParentUpdate.new.set_parent(content_id,
                                              parent_taxon_id: parent,
                                              associated_taxon_ids: associated_taxons)
    rescue GdsApi::HTTPUnprocessableEntity => e
      # Since we cannot easily differentiate the reasons for getting a 422
      # error code, we do a lookup to see if a content item with the slug
      # already exists, and if so, provide a more customised error message.
      existing_content_id = Services.publishing_api.lookup_content_id(
        base_path: taxon.base_path,
        with_drafts: true,
      )

      if existing_content_id.present?
        taxon_path = Rails.application.routes.url_helpers.taxon_path(existing_content_id)
        error_message = I18n.t('errors.invalid_taxon_base_path', taxon_path: taxon_path)
        raise(InvalidTaxonError, ActionController::Base.helpers.sanitize(error_message))
      else
        GovukError.notify(e)
        raise(InvalidTaxonError, I18n.t('errors.invalid_taxon'))
      end
    end

  private

    def payload
      Taxonomy::BuildTaxonPayload.call(taxon: taxon)
    end
  end
end
