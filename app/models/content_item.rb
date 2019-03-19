class ContentItem
  attr_reader(
    :content_id,
    :title,
    :base_path,
    :publishing_app,
    :rendering_app,
    :document_type,
    :state,
  )

  attr_writer :link_set

  def initialize(data, blacklist: Rails.configuration.blacklisted_tag_types)
    @blacklist = blacklist
    @content_id = data.fetch('content_id')
    @title = data.fetch('title')
    @base_path = data.fetch('base_path')
    @publishing_app = data.fetch('publishing_app', nil)
    @rendering_app = data.fetch('rendering_app', nil)
    @document_type = data.fetch('document_type')
    @state = data.fetch('state', nil)
  end

  def self.find!(content_id)
    content_item = Services.publishing_api.get_content(content_id)
    raise ItemNotFoundError if content_item['document_type'].in?(%w[redirect gone])

    new(content_item.to_h)
  rescue GdsApi::HTTPNotFound
    raise ItemNotFoundError
  end

  def draft?
    state == 'draft'
  end

  def link_set
    @link_set ||= Tagging::ContentItemExpandedLinks.find(content_id)
  end

  def facets_link_set
    @facets_link_set ||= Facets::ContentItemExpandedLinks.find(content_id)
  end

  def taxons?
    link_set.taxons.present?
  end

  def blacklisted_tag_types
    document_blacklist = Array(blacklist[publishing_app]).map(&:to_sym)
    document_blacklist += additional_temporary_blacklist

    unless related_links_are_renderable?
      document_blacklist += [:ordered_related_items]
    end

    unless taxons?
      document_blacklist += [:ordered_related_items_overrides]
    end

    document_blacklist
  end

  def allowed_tag_types
    Tagging::ContentItemExpandedLinks::TAG_TYPES - blacklisted_tag_types
  end

  class ItemNotFoundError < StandardError
  end

private

  attr_accessor :blacklist

  def related_links_are_renderable?
    %w[
      answer
      calculator
      calendar
      contact
      guide
      help_page
      licence
      local_transaction
      place
      programme
      simple_smart_answer
      smart_answer
      transaction
      travel_advice
    ].include?(document_type)
  end

  def additional_temporary_blacklist
    publishing_app == 'specialist-publisher' && document_type == 'finder' ? [:topics] : []
  end
end
